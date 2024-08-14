class_name UpgradeNode extends Button;


enum UpgradeState {
	HIDDEN,
	LOCKED,
	UNLOCKED_NOT_AFFORDABLE,
	UNLOCKED_AFFORDABLE,
	PURCHASED,
}


@onready var test_counter = upgrade.required;
var business : RefCounted;
var upgrade : Upgrade;
var state : UpgradeState:
	get:
		return state;
	set(value):
		state = value;
		self.visible = self.state != UpgradeState.HIDDEN;
		self.disabled = (self.state != UpgradeState.UNLOCKED_AFFORDABLE
			and self.state != UpgradeState.PURCHASED);
		if value == UpgradeState.PURCHASED:
			modulate = Color.AQUA

var previous : Button = null;


func _ready():
	update();
	self.text = str(upgrade.required);
	EventBus.update_framerule.connect(_on_framerule_update);


func _process(delta):
	update();


func update():
	self.state = get_state();


func get_state() -> UpgradeState:
	if upgrade.purchased:
		return UpgradeState.PURCHASED;
	if previous == null:
		# first one is never hidden (of course when there's at least
		# one business purchased)
		# but seems like we don't need a specific condtion in here
		# since it's jut gonna return UNLOCKED_AFFORDABLE in the end
		if business.count < upgrade.required:
			return UpgradeState.HIDDEN;
		if Game.counter < upgrade.price:
			return UpgradeState.UNLOCKED_NOT_AFFORDABLE;
	else:
		if previous.state == UpgradeState.LOCKED or previous.state == UpgradeState.HIDDEN:
			return UpgradeState.HIDDEN;
		if business.count < upgrade.required:
			return UpgradeState.LOCKED;
		if Game.counter < upgrade.price:
			return UpgradeState.UNLOCKED_NOT_AFFORDABLE;
	return UpgradeState.UNLOCKED_AFFORDABLE;


func _on_pressed():
	if Game.counter >= upgrade.price and not upgrade.purchased:
		EventBus.upgrade_purchased.emit(self.business, self.upgrade);


# when is it called?
# seems like it isn't called anywhere bruh
func _update_tooltip():
	tooltip_text = "### **" + upgrade.full_name + "**\n\n";
	tooltip_text += "Cost: " + Globals.format_num(upgrade.price) + '\n';
	tooltip_text += "Required: ";
	if business.count < upgrade.required:
		tooltip_text += "[color=#ff6666]";
	else:
		tooltip_text += "[color=white]";
	tooltip_text += str(upgrade.required) + "[/color]\n";
	tooltip_text += upgrade.effect + '\n\n';
	tooltip_text += '*' + upgrade.description + '*';


func _make_custom_tooltip(for_text):
	var lbl := MarkdownLabel.new();
	lbl._set_markdown_text(for_text);
	lbl.fit_content = true;
	lbl.custom_minimum_size = Vector2(300, 100);
	return lbl;


func _on_framerule_update():
	# this method is to process_mode like is_visible_in_tree() is to visible:
	# it's basically apparently the "evaluated" process mode of the node
	if can_process():
		_update_tooltip();
