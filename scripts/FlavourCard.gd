class_name FlavourCard extends PanelContainer;


# like this fur now
enum FlavourState {
	UNLOCKED,
	PURCHASED,
};


var flavour: Flavour;
@onready var state : FlavourState = (FlavourState.PURCHASED
	if flavour.purchased else FlavourState.UNLOCKED):
		get:
			return state;
		set(value):
			if value == FlavourState.UNLOCKED:
				pass
			elif value == FlavourState.PURCHASED:
				$HBoxContainer/Button.text = 'Purchased!';


func _ready():
	assert(flavour != null, 'Flavour is not set for flavour card ' + str(self));
	$HBoxContainer/VBoxContainer/FlavourName.text = flavour.full_name;
	$HBoxContainer/VBoxContainer/Price.text = Globals.format_num(flavour.price);
	var bonus_percent : float;
	if flavour.short_name == 'vanilla':
		bonus_percent = 100.0;
	else:
		bonus_percent = flavour.bonus * 100;
	tooltip_text = 'Production multiplier: +' + String.num(bonus_percent, 2) + '%\n' + flavour.description;


func _process(delta):
	$HBoxContainer/Button.disabled = (flavour.price > Game.counter
		or state == FlavourState.PURCHASED);


func _on_button_pressed():
	if Game.counter >= flavour.price:
		state = FlavourState.PURCHASED;
		EventBus.flavour_purchased.emit(flavour);
