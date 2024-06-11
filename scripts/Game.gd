extends Node


# can't make this const sadge
@onready var BUSINESSES_INFO : Array = ResourceLoader.load("res://data/businesses.json").data;

var counter : float = 0;
var businesses : Array;


class Business:
	var id: int;
	var short_name: String;
	var full_name: String;
	var description: String;
	var initial_price: float;
	var price: float;
	var multiplier: float;
	var count: float;
	var initial_production: float;
	var production: float;
	var production_all_time: float;
	
	func _init(_id: int, entry: Dictionary):
		id = _id
		short_name = entry["name"];
		full_name = entry["full_name"];
		description = entry["description"];
		initial_price = entry["initial_price"];
		price = entry["initial_price"];
		multiplier = entry["multiplier"];
		count = 0;
		initial_production = entry["initial_production"];
		production = entry["initial_production"];
		production_all_time = 0;
	
	func basic_production_rate(delta: float):
		return production * count * delta;


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Game autoload loaded");
	for i in range(BUSINESSES_INFO.size()):
		var b := Business.new(i + 1, BUSINESSES_INFO[i]);
		businesses.append(b);
