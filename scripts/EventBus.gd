extends Node


signal business_purchased(business: Business, amount: int);
signal upgrade_purchased(business: Business, upgrade: Upgrade);
signal flavour_purchased(flavour: Flavour);
signal tech_purchased(tech: Tech);
signal update_fastest;
signal update_framerule;
signal update_slow;


func _ready():
	print('EventBus autoload loaded');
