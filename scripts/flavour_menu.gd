class_name FlavourMenu extends PanelContainer;


static var card_packed : PackedScene = preload("res://scenes/FlavourCard.tscn");

var unlocked_flavours : Array;

@onready var flavour_list : VBoxContainer = $VBoxContainer/ScrollContainer/FlavourList;
@onready var exit_button : Button = $VBoxContainer/ExitBtn;
@onready var bank_counter = $VBoxContainer/BankCounter;


# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.update_framerule.connect(_update_flavour_list);
	EventBus.update_fastest.connect(_update_counter);
	for f in Game.flavours_arr.filter(func(f : Flavour):
			return Game.counter_all_time >= f.unlocked_at):
		add_flavour(f);


func add_flavour(f: Flavour):
	unlocked_flavours.append(f);
	var card : FlavourCard = card_packed.instantiate();
	card.flavour = f;
	flavour_list.add_child(card);


func hide_menu():
	visible = false;
	process_mode = Node.PROCESS_MODE_DISABLED;


func show_menu():
	visible = true;
	process_mode = Node.PROCESS_MODE_INHERIT;
	_update_flavour_list();
	_update_counter();


func force_update():
	_update_flavour_list();
	_update_counter();


func _update_flavour_list():
	if can_process():
		for f in Game.flavours_arr:
			if f not in unlocked_flavours and Game.counter_all_time >= f.unlocked_at:
				add_flavour(f);
		$VBoxContainer/Label.text = 'Total multiplier: x' + Globals.format_num(
			Game.multipliers['flavours'], 3
		);


func _update_counter():
	if can_process():
		bank_counter.text = 'You have: ' + Globals.format_num(Game.counter);
