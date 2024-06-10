extends Node


# can't make this const sadge
@onready var BUSINESSES_INFO : Array = ResourceLoader.load("res://data/businesses.json").data;

var counter : float = 0;

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Game autoload loaded");
	load_data();
	pass # Replace with function body.


func save_data():
	pass


func load_data():
	pass
