class_name Tech extends RefCounted;


var id : int;
var short_name : String;
var full_name : String;
var effect : String;
var description : String;
var price : float;
var purchased : bool;
# probably won't need any connections in here if it's
# gonna be how i envision this :clueless:


func _init(id: int, entry: Dictionary):
	self.id = id;
	self.short_name = entry['short_name'];
	self.full_name = entry['full_name'];
	self.effect = entry['effect'];
	self.description = entry['description'];
	self.price = entry['price'];
	self.purchased = false;
