extends Node


# can't make this const sadge
@onready var BUSINESSES_INFO : Array = ResourceLoader.load("res://data/businesses.json").data;

var counter : float = 0;
var businesses : Array;

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Game autoload loaded");
	for b:Dictionary in BUSINESSES_INFO:
		var b_copy := b.duplicate(true);
		b_copy.merge({
			"price": b["initial_price"],
			"production": b["initial_production"],
			"count": 0,
			"production_all_time": 0,
		});
		businesses.append(b_copy);
	pass # Replace with function body.
