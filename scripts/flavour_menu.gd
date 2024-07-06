extends PanelContainer;


static var card_packed : PackedScene = preload("res://scenes/FlavourCard.tscn");

var unlocked_flavours : Array;

@onready var flavour_list := $VBoxContainer/ScrollContainer/FlavourList;


# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.update_framerule.connect(_update_flavour_list);
	for f in Game.flavours_arr.filter(func(f : Flavour):
			return Game.counter_all_time >= f.unlocked_at):
		add_flavour(f);


func add_flavour(f: Flavour):
	unlocked_flavours.append(f);
	var card : FlavourCard = card_packed.instantiate();
	card.flavour = f;
	flavour_list.add_child(card);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _update_flavour_list():
	for f in Game.flavours_arr:
		if f not in unlocked_flavours and Game.counter_all_time >= f.unlocked_at:
			add_flavour(f);
	$VBoxContainer/Label.text = 'Total multiplier: x' + Globals.format_num(
		Game.multipliers['flavours'], 3
	);
