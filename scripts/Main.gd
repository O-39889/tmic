extends Control


const COUNTER_UPDATE_FASTEST : float = 1 / 15;
const COUNTER_UPDATE_FRAMERULE : float = 0.35; # hehe
const COUNTER_UPDATE_SLOW : float = 0.7;

var fastest_tick : float = 0;

@onready var FPS : int = Engine.physics_ticks_per_second;

@onready var b_control := preload("res://scenes/Business.tscn");
@onready var click_label := preload("res://scenes/FloatingLabel.tscn");

@onready var businesses_list := find_child("BusinessesList");
@onready var bank_counter := find_child("BankCounter")
@onready var ips_counter := find_child("IpsCounter");


var business_nodes: Dictionary;


# Called when the node enters the scene tree for the first time.
func _ready():
	get_window().min_size = Vector2i(1024, 768);
	print("Main scene loaded");
	# no!! should actually only add the unlocked ones
	for b in Game.businesses:
		var b_node := b_control.instantiate();
		b_node.business = b;
		businesses_list.add_child(b_node);
		business_nodes[b.short_name] = b_node;
		b_node.business_purchased.connect(_on_business_purchased);


# for updating UI stuff (counters etc)
func _process(delta):
	fastest_tick += delta;
	if fastest_tick >= COUNTER_UPDATE_FASTEST:
		fastest_tick = 0;
		update_counter();
		update_ips();
	pass


# for updating game logic stuff (production etc)
func _physics_process(delta):
	var ips : float = 0;
	for b in Game.businesses:
		if b.count > 0:
			var produced : float = b.base_produce(delta);
			
			# and other multipliers as well
			produced *= Game.multipliers["flavours"];
			
			b.production_all_time += produced;
			ips += produced;
			Game.counter += produced;
	ips /= delta;
	Game.ips = ips;
	update_ips();


func update_counter():
	bank_counter.text = Globals.format_num(Game.counter);


func update_ips():
	ips_counter.text = 'per second: ' + Globals.format_num(Game.ips, 2);


func _on_business_purchased(short_name: String, amount: int):
	var b_node : PanelContainer = business_nodes[short_name];
	b_node.business.count += 1;
	var current_price : float = b_node.business.price;
	b_node.business.price = floorf(b_node.business.initial_price * pow(b_node.business.multiplier, b_node.business.count));
	b_node.update();
	var game_b;
	Game.counter -= current_price;


func _on_button_pressed():
	var produced : float = Game.get_click_production();
	Game.counter += produced;
	update_counter();
	var pos := get_viewport().get_mouse_position();
	var label := click_label.instantiate();
	label.text = Globals.format_num(produced);
	label.position = pos - Vector2(0, 25);
	add_child(label);
