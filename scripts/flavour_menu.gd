extends PanelContainer;


# Called when the node enters the scene tree for the first time.
func _ready():
	for f in Game.flavours_arr:
		var card : FlavourCard = load("res://scenes/FlavourCard.tscn").instantiate();
		card.flavour = f;
		$VBoxContainer/ScrollContainer/FlavourList.add_child(card);
		print(card.flavour.full_name);
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
