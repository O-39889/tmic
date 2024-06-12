extends Control

signal business_purchased(short_name, amount)

var business;
@onready var b_name := $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/Name;
@onready var b_count := $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/Count;
@onready var b_price := $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/Price;
@onready var b_utton := $PanelContainer/MarginContainer/HBoxContainer/BuyButton

var next_price: float;

func _ready():
# assume that the business is already set in there
	if business == null:
		print("Error: business for business node " + str(self) + " is not set"); 
		return;
	b_name.text = str(business.full_name);
	b_count.text = str(business.count)
	b_price.text = Globals.format_num(business.price);


func _on_buy_button_pressed():
	if business.price <= Game.counter:
		emit_signal("business_purchased", business.short_name, 1);


func _process(delta):
	b_utton.disabled = business.price > Game.counter;
