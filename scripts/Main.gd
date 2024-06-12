extends Control


const COUNTER_UPDATE_FASTEST : float = 1 / 15;
const COUNTER_UPDATE_FRAMERULE : float = 0.35; # hehe
const COUNTER_UPDATE_SLOW : float = 0.7;

var fastest_tick : float = 0;

@onready var FPS : int = Engine.physics_ticks_per_second;

@onready var b_control := preload("res://scenes/Business.tscn");


var business_nodes: Dictionary;

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Main scene loaded");
	for b in Game.businesses:
		var b_node := b_control.instantiate();
		b_node.business = b;
		$ScrollContainer/VBoxContainer.add_child(b_node);
		business_nodes[b.short_name] = b_node;
		b_node.business_purchased.connect(_on_business_purchased);


# for updating UI stuff (counters etc)
func _process(delta):
	fastest_tick += delta;
	if fastest_tick >= COUNTER_UPDATE_FASTEST:
		fastest_tick = 0;
		update_counter();
	pass


# for updating game logic stuff (production etc)
func _physics_process(delta):
	for b in Game.businesses:
		if b.count > 0:
			var produced : float = b.base_produce(delta);
			produced *= Game.multipliers["flavours"];
			b.production_all_time += produced;
			Game.counter += produced;
	pass


func update_counter():
	$TestLbl.text = Globals.format_num(Game.counter);


func _on_business_purchased(short_name: String, amount: int):
	var b_node : PanelContainer = business_nodes[short_name];
	b_node.business.count += 1;
	print(b_node.business);
	var current_price : float = b_node.business.price;
	b_node.business.price = floorf(b_node.business.initial_price * pow(b_node.business.multiplier, b_node.business.count));
	b_node.update();
	var game_b;
	for b in Game.businesses:
		if b.short_name == short_name:
			print(b);
	Game.counter -= current_price;


func _on_button_pressed():
	Game.counter += Game.get_click_production();
	update_counter();
