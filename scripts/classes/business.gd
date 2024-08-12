class_name Business extends RefCounted;


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
var upgrades: Array[Upgrade];


func _init(id: int, entry: Dictionary):
	self.id = id;
	self.short_name = entry["name"];
	self.full_name = entry["full_name"];
	self.description = entry["description"];
	self.initial_price = entry["initial_price"];
	self.price = entry["initial_price"];
	self.multiplier = entry["multiplier"];
	self.initial_production = entry["initial_production"];
	self.production = entry["initial_production"];
	
	self.production_all_time = 0;
	self.count = 0;
	
	for i in range(entry['upgrades'].size()):
		# IDs start with 1 instead of 0 !
		self.upgrades.append(Upgrade.new(i + 1, entry['upgrades'][i], self));


func base_produce(delta: float) -> float: 
	return self.production * self.count * delta;;
