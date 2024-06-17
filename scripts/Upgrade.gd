extends Button


enum UpgradeState {
	HIDDEN,
	LOCKED,
	UNLOCKED_NOT_AFFORDABLE,
	UNLOCKED_AFFORDABLE,
	PURCHASED,
}


var business : RefCounted;
var upgrade : Dictionary;
var state : UpgradeState;
var previous : Button = null;


func _ready():
	update();
	self.text = str(upgrade["required"]);


func _process(delta):
	update();


func update():
	self.state = get_state();
	self.visible = self.state != UpgradeState.HIDDEN;
	self.disabled = self.state != UpgradeState.UNLOCKED_AFFORDABLE and self.state != UpgradeState.PURCHASED;


func get_state() -> UpgradeState:
	'''
	1) if the upgrade is purchased then display it (of course)
	2) if it's already displayed then continue to display it
	3) if it's the first upgrade then always display it
	4) otherwise, if the previous upgrade is locked or hidden then hide it
	5) 
	'''
	if upgrade["purchased"]:
		return UpgradeState.PURCHASED;
	if previous == null:
		# first one is never hidden
		if business.count < upgrade["required"]:
			return UpgradeState.LOCKED;
		if Game.counter < upgrade["price"]:
			return UpgradeState.UNLOCKED_NOT_AFFORDABLE;
	else:
		if previous.state == UpgradeState.LOCKED or previous.state == UpgradeState.HIDDEN:
			return UpgradeState.HIDDEN;
		if business.count < upgrade["required"]:
			return UpgradeState.LOCKED;
		if Game.counter < upgrade["price"]:
			return UpgradeState.UNLOCKED_NOT_AFFORDABLE;
	return UpgradeState.UNLOCKED_AFFORDABLE;


func _on_pressed():
	print(upgrade["full_name"]);


func _update_tooltip():
	tooltip_text = "### **" + upgrade["full_name"] + "**\n\n";
	tooltip_text += "*Cost:* " + Globals.format_num(upgrade["price"]) + '\n';
	tooltip_text += '**' + upgrade["effect"] + '**' + '\n';
	tooltip_text += '*' + upgrade["description"] + '*' + '\n';


func _make_custom_tooltip(for_text):
	var lbl := MarkdownLabel.new();
	lbl._set_markdown_text(for_text);
	print(lbl.markdown_text);
	return lbl;
