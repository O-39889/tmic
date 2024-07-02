class_name Upgrade extends RefCounted;


var id: int;
var short_name: String;
var full_name: String;
var description: String;
var effect: String;
var price: float;
var required: int;
var purchased: bool;
var business: Business;


func _init(id: int, entry: Dictionary, business: Business):
	self.id = id;
	self.short_name = entry.short_name;
	self.full_name = entry.full_name;
	self.description = entry.description;
	self.effect = entry.effect;
	self.price = entry.price;
	self.required = entry.required;
	self.business = business;
	
	self.purchased = false;
