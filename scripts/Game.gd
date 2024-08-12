extends Node;

# can't make this const sadge
var BUSINESSES_INFO : Array = ResourceLoader.load("res://data/businesses.json").data;
var FLAVOURS_INFO : Array = ResourceLoader.load("res://data/flavours.json").data;
var TECHS_INFO : Array = ResourceLoader.load('res://data/techs.json').data;

var counter : float = 0;
var counter_all_time : float = 0;

var base_click_production : float = 1;
var clicks : int = 0;
var ic_clicked : float = 0;
var clicks_all_time : int = 0;
var ic_clicked_all_time : float = 0;

var ips : float = 0;

var multipliers := {};

var bs_arr: Array[Business] = [];		# READ-ONLY
var bs_dict: Dictionary = {};			# READ-ONLY

var flavours_arr : Array[Flavour] = [];	# READ-ONLY
var flavours_dict := {};				# READ-ONLY
var purchased_flavours : Array[Flavour] = [];

## Read-only dictionary of read-only arrays.
## Keys: short string IDs of businesses.
## Values: arrays of Upgrade objects corresponding to each business.
var upgrades := {};		# READ-ONLY
var purchased_upgrades : Array[Upgrade] = [];

## Read-only array and dictionary of techs available in the game.
## Order in the tech tree does not matter.
var techs_arr : Array[Tech] = [];		# READ-ONLY
var techs_dict : Dictionary = {};		# READ-ONLY
var purchased_techs : Array[Tech] = [];

## Used afterwards as well.
@onready var savedata : SaveData = SaveLoadManager.load_autosave();


# Called when the node enters the scene tree for the first time.
func _ready():
	if savedata:
		print('Savedata loaded');
	else:
		print('No savedata loaded');
	# at around 40k or so maybe could put the next business but that's without any flavours and upgrades
	print("Game autoload loaded");
	# initializing businesses and upgrades
	for i in range(BUSINESSES_INFO.size()):
		# New upgrades are created in BUSINESS CLASS ITSELF
		# PLEASE KEEP THAT IN MIND
		# IDs start from 1 instead of 0 !
		# the same with upgrades in the business class itself!!!
		var b := Business.new(i + 1, BUSINESSES_INFO[i]);
		bs_arr.append(b);
		bs_dict[b.short_name] = b;
		upgrades[b.short_name] = b.upgrades.duplicate();
	bs_arr.make_read_only();
	bs_dict.make_read_only();
	for b_key in upgrades.keys():
		upgrades[b_key].make_read_only();
	upgrades.make_read_only();
	
	# initializing flavours
	var vanilla_entry : Dictionary = FLAVOURS_INFO[0];
	# TODO: start IDs from 1 instead of 0
	var vanilla_flavour := Flavour.new(1, vanilla_entry);
	vanilla_flavour.purchased = true;
	flavours_dict[vanilla_flavour.short_name] = vanilla_flavour;
	flavours_arr = [vanilla_flavour];
	purchased_flavours = [vanilla_flavour];
	for i in range(1, FLAVOURS_INFO.size()):
		var f : Flavour = Flavour.new(i + 1, FLAVOURS_INFO[i]);
		flavours_dict[f.short_name] = f;
		flavours_arr.append(f);
	flavours_arr.make_read_only();
	flavours_dict.make_read_only();
	
	#initializing techs
	for i in range(TECHS_INFO.size()):
		var t : Tech = Tech.new(i + 1,TECHS_INFO[i]);
		techs_arr.append(t);
		techs_dict[t.short_name] = t;
	techs_arr.make_read_only();
	techs_dict.make_read_only();
	
	reset_multipliers();
	
	if savedata:
		load_savedata();


func load_savedata():
	if savedata == null:
		return;
	reset_multipliers();
	counter = savedata.ic_in_bank;
	counter_all_time = savedata.ic_all_time;
	clicks = savedata.clicks;
	clicks_all_time = savedata.clicks_all_time;
	ic_clicked = savedata.ic_clicked;
	ic_clicked_all_time = savedata.ic_clicked_all_time;
	
	# first, go over the businesses
	for b in bs_arr:
		if savedata.businesses.has(b.short_name):
			set_business(b, savedata.businesses[b.short_name]);
		else:
			set_business(b, 0);
	
	# then, the flavours
	# first, reset them
	reset_flavours();
	for f : Flavour in flavours_arr:
		if savedata.flavours.has(f.short_name):
			apply_flavour(f);
	
	# then, the business upgrades
	# first, reset them as well
	reset_upgrades();
	for b_key in upgrades:
		for u : Upgrade in upgrades[b_key]:
			if savedata.upgrades.has(b_key)\
			and savedata.upgrades[b_key].has(u.short_name):
				apply_upgrade(u);
	
	# finally, the techs
	# first, reset them
	reset_techs();
	for t : Tech in techs_arr:
		if savedata.techs.has(t.short_name):
			apply_tech(t);


func save_savedata():
	var save := SaveData.default();
	save.player_name = savedata.player_name;
	
	save.game_started = savedata.game_started;
	save.current_run_started = savedata.current_run_started;
	save.last_saved = Time.get_unix_time_from_system();
	save.amount_of_resets = savedata.amount_of_resets;
	
	save.ic_in_bank = counter;
	save.ic_this_run = counter_all_time;
	save.ic_all_time = counter_all_time;
	
	save.ic_clicked = ic_clicked;
	save.ic_clicked_all_time = ic_clicked_all_time;
	save.clicks = clicks;
	save.clicks_all_time = clicks_all_time;
	
	for b : Business in bs_arr:
		if b.count != 0 or true:
			save.businesses[b.short_name] = b.count;
	
	# upgrades are a PITA
	
	for f : Flavour in purchased_flavours:
		if f.short_name != 'vanilla':
			save.flavours.append(f.short_name);
	
	for t : Tech in purchased_techs:
		save.techs.append(t.short_name);
	
	SaveLoadManager.save_game(save);
	savedata = save;


func get_click_production():
	return 6e9 * multipliers['click'];


func reset_flavours():
	var vanilla_flavour : Flavour = flavours_arr.front();
	if vanilla_flavour == null or vanilla_flavour.short_name != 'vanilla':
		printerr('Warning, first value in the flavour array is assumed to always be vanilla (default)');
	purchased_flavours.clear();
	purchased_flavours.append(vanilla_flavour);


func reset_upgrades():
	purchased_upgrades.clear();


func reset_techs():
	purchased_techs.clear();


func reset_multipliers():
	multipliers = {
		'flavours': 1.0,
		'click': 1.0,
		'businesses': {}
	};
	for b : Business in bs_arr:
		multipliers['businesses'][b.short_name] = 1.0;


func purchase_business(b: Business, amount: int = 1):
	if amount != 1:
		printerr('Warning: logic for buying multiple instances of a business not set, subtracting only the price of the first business...');
	counter -= b.price;
	set_business(b, b.count + amount);


func purchase_flavour(f: Flavour):
	assert(not f.purchased, 'This flavour ' + f.short_name + ' is already purrchased');
	counter -= f.price;
	apply_flavour(f);


func purchase_upgrade(u: Upgrade):
	assert(not u.purchased, 'This upgrade ' + u.short_name + ' is already purchased');
	counter -= u.price;
	apply_upgrade(u);


func purchase_tech(t: Tech):
	assert(not t.purchased, 'This tech ' + t.short_name + ' is already purchased');
	counter -= t.price;
	apply_tech(t);


func set_business(b: Business, amount: int):
	b.count = amount;
	b.price = floorf(b.initial_price * pow(b.multiplier, b.count));


## A separate function for applying the gameplay effects of flavours.
## Will be used when loading save data instead of purchasing.
func apply_flavour(f: Flavour):
	if f.purchased:
		return;
	f.purchased = true;
	# ???
	purchased_flavours.insert(purchased_flavours.bsearch_custom(
		f, func(arr_item: Flavour, needle: Flavour): return arr_item.id < needle.id,
		false
	), f);
	multipliers['flavours'] *= 1.0 + f.bonus;


## A separate function for applying the gameplay effects of upgrades.
## Will be used when loading save data instead of purchasing.
func apply_upgrade(u: Upgrade):
	if u.purchased:
		return;
	u.purchased = true;
	purchased_upgrades.append(u);
	purchased_upgrades.sort_custom(func(a: Upgrade, b: Upgrade):
		if a.business.id != b.business.id:
			return a.business.id < b.business.id;
		return a.id < b.id;
		);
	# and applying the effect itself
	var id := u.short_name;
	if id.begins_with('cooler_bag'):
		match id:
			_:
				Game.multipliers["businesses"]["cooler_bag"] *= 2.0;
	elif id.begins_with('cart'):
		match id:
			_:
				Game.multipliers['businesses']['cart'] *= 2.0;
	elif id.begins_with('van'):
		match id:
			_:
				Game.multipliers['businesses']['van'] *= 2.0;
	elif id.begins_with('parlor'):
		match id:
			_:
				Game.multipliers['businesses']['van'] *= 2.0;


func apply_tech(t: Tech):
	if t.purchased:
		return;
	purchased_techs.append(t);
	# and also apply its effect as well
	if t.short_name in ['ext_whisk', 'refrigerants_1', 'auto_whisk']:
		multipliers['click'] *= 2.0;
