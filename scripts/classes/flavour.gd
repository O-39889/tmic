class_name Flavour extends RefCounted;


var id: int;
var short_name: String;
var full_name: String;
var description: String;
var price: float;
var unlocked_at: float;
var bonus: float;
var purchased: bool;


func _init(id: int, entry: Dictionary):
	self.id = id;
	self.short_name = entry['short_name'];
	self.full_name = entry['full_name'];
	self.description = entry['description'];
	self.price = entry['price'];
	self.unlocked_at = entry['unlocked_at'];
	self.bonus = entry['bonus'];
	self.purchased = false;
