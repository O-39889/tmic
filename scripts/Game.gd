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

var flavours_dict := {};
var flavours_arr := [];
var purchased_flavours := [];

var upgrades := {};
var purchased_upgrades := [];


# Called when the node enters the scene tree for the first time.
func _ready():
	# at around 40k or so maybe could put the next business but that's without any flavours and upgrades
	print("Game autoload loaded");
	for i in range(BUSINESSES_INFO.size()):
		# New upgrades are created in BUSINESS CLASS ITSELF
		# PLEASE KEEP THAT IN MIND
		var b := Business.new(i, BUSINESSES_INFO[i]);
		bs_arr.append(b);
		bs_dict[b.short_name] = b;
		upgrades[b.short_name] = b.upgrades.duplicate();
	var vanilla_entry : Dictionary = FLAVOURS_INFO[0]
	var vanilla_flavour := Flavour.new(0, vanilla_entry);
	vanilla_flavour.purchased = true;
	flavours_dict[vanilla_flavour.short_name] = vanilla_flavour;
	flavours_arr = [vanilla_flavour];
	purchased_flavours = [vanilla_flavour];
	multipliers["flavours"] = 1.0;
	for i in range(1, FLAVOURS_INFO.size()):
		var f : Flavour = Flavour.new(i, FLAVOURS_INFO[i]);
		flavours_dict[f.short_name] = f;
		flavours_arr.append(f);
	
	multipliers["businesses"] = {};
	for b in bs_arr:
		multipliers["businesses"][b.short_name] = 1.0;


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


func purchase_flavour(f: Flavour):
	assert(not f.purchased, 'This flavour ' + f.short_name + ' is already purrchased');
	f.purchased = true;
	Game.counter -= f.price;
	# ???
	purchased_flavours.insert(purchased_flavours.bsearch_custom(
		f, func(arr_item: Flavour, needle: Flavour): return arr_item.id < needle.id,
		false  
	), f);
	multipliers['flavours'] *= 1.0 + f.bonus;


func purchase_upgrade(u: Upgrade):
	assert(not u.purchased, 'This upgrade ' + u.short_name + ' is already purchased');
	u.purchased = true;
	Game.counter -= u.price;
	purchased_upgrades.insert(purchased_upgrades.bsearch_custom(
		u, func(a: Upgrade, b: Upgrade):
			# prolly???
			if a.business.id < b.business.id:
				return true;
			return a.id < b.id,
			false
	), u);
