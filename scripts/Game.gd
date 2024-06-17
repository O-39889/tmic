extends Node

# can't make this const sadge
@onready var BUSINESSES_INFO : Array = ResourceLoader.load("res://data/businesses.json").data;
@onready var FLAVOURS_INFO : Array = ResourceLoader.load("res://data/flavours.json").data;

var counter : float = 0;
var counter_all_time : float = 0;
# I think I'll need to refactor it someday to only use dictionaries
# or maybe even both so that I could
var bs_arr: Array[Business];
var bs_dict: Dictionary;

var base_click_production : float = 1;
var clicks : int = 0;

var ips : float = 0;

var multipliers := {};

var flavours := {};
var upgrades := {};


class Business:
	var id: int;
	var short_name: String;
	var full_name: String;
	var description: String;
	var initial_price: float;
	var price: float;
	var multiplier: float;
	var count: int;
	var initial_production: float;
	var production: float;
	var production_all_time: float;
	var upgrades: Array;
	
	func _init(_id: int, entry: Dictionary):
		self.id = _id
		self.short_name = entry["name"];
		self.full_name = entry["full_name"];
		self.description = entry["description"];
		self.initial_price = entry["initial_price"];
		self.price = entry["initial_price"];
		self.multiplier = entry["multiplier"];
		self.count = 0;
		self.initial_production = entry["initial_production"];
		self.production = entry["initial_production"];
		self.production_all_time = 0;
		self.upgrades = entry["upgrades"];
		
		for u in self.upgrades:
			u["purchased"] = false;
	
	
	func base_produce(delta: float) -> float: 
		return self.production * self.count * delta;;


# Called when the node enters the scene tree for the first time.
func _ready():
	# at around 40k or so maybe could put the next business but that's without any flavours and upgrades
	print("Game autoload loaded");
	for i in range(BUSINESSES_INFO.size()):
		var b := Business.new(i, BUSINESSES_INFO[i]);
		bs_arr.append(b);
		bs_dict[b.short_name] = b;
		upgrades[b.short_name] = {};
	var vanilla_flavour : Dictionary = FLAVOURS_INFO[0];
	flavours[vanilla_flavour["short_name"]] = vanilla_flavour;
	multipliers["flavours"] = vanilla_flavour["bonus"];


func get_click_production():
	var click_production := base_click_production;
	# let's imagine that we have synergy techs/upgrades
	# that boost our base clicking production per every purchased business
	if multipliers.has("clicking_synergies"):
		for short_name in multipliers["clicking_synergies"]:
			# oops! that's not a dictionary!! yet
			if bs_dict[short_name].count > 0:
				# let's imagine that, for each synergy,
				# base clicking production increases
				# by 0.1 for every N^3 businesses owned
				# (where N is the ordinal number of the business
				# type) but I'm not exactly sure
				click_production += 0.1 * (bs_dict[short_name].count / pow(bs_dict[short_name].id + 1, 3));
	return click_production;
