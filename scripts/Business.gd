class_name BusinessNode extends Control;


enum BusinessState {
	# all business after a locked one
	HIDDEN,
	# everything hidden and replaced with ???
	# comes after the last unlocked business
	LOCKED,
	# becomes unlocked when the player has at least half
	# of its initial cost (probably, might tweak later)
	UNLOCKED,
}


var business : Business;
@onready var b_name := find_child("Name");
@onready var b_count := find_child("Count");
@onready var b_price := find_child("Price");
@onready var b_utton := find_child("BuyButton");
@onready var upgrades_list := find_child("UpgradesList");

@onready var upgrade_scene := preload("res://scenes/Upgrade.tscn");

var state : BusinessState = BusinessState.HIDDEN:
	get:
		return state;
	set(value):
		assert(state >= BusinessState.HIDDEN
		and state <= BusinessState.UNLOCKED);
		state = value;
		match state:
			BusinessState.HIDDEN:
				self.visible = false;
				return;
			BusinessState.LOCKED:
				self.visible = true;
				self.upgrades_list.visible = false;
				return;
			BusinessState.UNLOCKED:
				self.visible = true;
				self.upgrades_list.visible = true;

var previous : Control = null;


func _ready():
# assume that the business is already set in there
	assert(business != null, 'Business for business node' + str(self) + ' not set');
	var previous_upgrade : Control = null;
	for u in business.upgrades:
		var upgrade_node := upgrade_scene.instantiate();
		upgrade_node.business = business;
		upgrade_node.upgrade = u;
		upgrade_node.previous = previous_upgrade;
		upgrades_list.add_child(upgrade_node);
		previous_upgrade = upgrade_node;
	update();


func update():
	self.state = get_state();
	if self.state == BusinessState.LOCKED:
		b_count.text = "";
		b_name.text = "???";
	else:
		b_count.text = str(business.count);
		b_name.text = business.full_name;
	b_price.text = '$' + Globals.format_num(business.price);
	b_utton.disabled = business.price > Game.counter;


func get_state() -> BusinessState:
	if business.count > 0:
		return BusinessState.UNLOCKED;
	if previous == null:
		return BusinessState.UNLOCKED;
	if previous.state == BusinessState.LOCKED or previous.state == BusinessState.HIDDEN:
		return BusinessState.HIDDEN;
	if self.state == BusinessState.UNLOCKED or Game.counter > business.initial_price / 2:
		return BusinessState.UNLOCKED;
	return BusinessState.LOCKED;
	# ???
	return BusinessState.UNLOCKED;


func _on_buy_button_pressed():
	if business.price <= Game.counter:
		EventBus.business_purchased.emit(self.business, 1);
		update();


func _process(delta):
	update();


func get_tooltip_node():
	# generate the node
	# seems like not lmao
	return null;
