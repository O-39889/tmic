extends Control

signal business_purchased(short_name, amount)

var business;
@onready var b_name := find_child("Name");
@onready var b_count := find_child("Count");
@onready var b_price := find_child("Price");
@onready var b_utton := find_child("BuyButton");
@onready var timer := find_child("TooltipTimer");
@onready var upgrades_list := find_child("UpgradesList");

@onready var upgrade_scene := preload("res://scenes/Upgrade.tscn");

var next_price: float;
var tooltip : Control = null;



func _ready():
# assume that the business is already set in there
	if business == null:
		print("Error: business for business node " + str(self) + " is not set"); 
		return;
	var previous_upgrade : Control = null;
	for u in business.upgrades:
		var upgrade := upgrade_scene.instantiate();
		upgrade.business = business;
		upgrade.upgrade = u;
		upgrade.previous = previous_upgrade;
		upgrades_list.add_child(upgrade);
		previous_upgrade = upgrade;
	b_name.text = str(business.full_name);
	update();


func update():
	b_count.text = str(business.count);
	b_price.text = Globals.format_num(business.price);


func _on_buy_button_pressed():
	if business.price <= Game.counter:
		emit_signal("business_purchased", business.short_name, 1);


func _process(delta):
	b_utton.disabled = business.price > Game.counter;


func _on_panel_container_mouse_entered():
	timer.start(1);
	pass;


func _on_panel_container_mouse_exited():
	if tooltip != null:
		tooltip.queue_free();
	timer.stop();
	b_utton.text = "Buy";


func _on_tooltip_timer_timeout():
	b_utton.text = "Tooltip";
