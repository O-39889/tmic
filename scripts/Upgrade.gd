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


func _process(delta):
	update();


func update():
	self.state = get_state();
	self.visible = self.state != UpgradeState.HIDDEN;
	self.disabled = self.state != UpgradeState.UNLOCKED_AFFORDABLE and self.state != UpgradeState.PURCHASED;


func get_state() -> UpgradeState:
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


func _on_mouse_entered():
	self.text = "¡¡¡";


func _on_mouse_exited():
	self.text = "!!!";
