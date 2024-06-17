extends Control

signal business_purchased(short_name, amount)


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


var business;
@onready var b_name := find_child("Name");
@onready var b_count := find_child("Count");
@onready var b_price := find_child("Price");
@onready var b_utton := find_child("BuyButton");
@onready var upgrades_list := find_child("UpgradesList");

@onready var upgrade_scene := preload("res://scenes/Upgrade.tscn");

var state : BusinessState = BusinessState.HIDDEN;
var previous : Control = null;


func _ready():
# assume that the business is already set in there
	if business == null:
		print("Error: business for business node " + str(self) + " is not set"); 
		return;
	var previous_upgrade : Control = null;
	for u in business.upgrades:
		var upgrade := upgrade_scene.instantiate();
		upgrade.business = business;
		upgrade.upgrade = u;
		upgrade.previous = previous_upgrade;
		upgrades_list.add_child(upgrade);
		previous_upgrade = upgrade;
	b_name.text = str(business.full_name);
	update();


func update():
	self.state = get_state();
	self.visible = self.state != BusinessState.HIDDEN;
	self.upgrades_list.visible = self.state == BusinessState.UNLOCKED;
	if self.state == BusinessState.LOCKED:
		b_count.text = "";
		b_name.text = "???";
	else:
		b_count.text = str(business.count);
		b_name.text = business.full_name;
	b_price.text = Globals.format_num(business.price);
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
	"""
	idk how are we gonna do dis
	basically:
		1) if it's the first node then make it unlocked automatically
		2) if it's not the first node and the previous node is
		either locked or hidden then make this one hidden
		3) if the player has more than half of its cost in bank
		then make it unlocked
		4) otherwise make it locked
		maybe i'll have to use the previous reference again?
		also i'll have to make it so that once it's unlocked it can't go locked again
	"""
	return BusinessState.UNLOCKED;


func _on_buy_button_pressed():
	if business.price <= Game.counter:
		emit_signal("business_purchased", business.short_name, 1);


func _process(delta):
	update();


func get_tooltip_node() -> Control:
	# generate the node
	return null;
