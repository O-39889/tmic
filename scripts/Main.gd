class_name Main extends Node;


enum View {
	MAIN,
	FLAVOURS,
	TECHS,
};


@onready var COUNTER_UPDATE_FASTEST : float = 1.0 / (Engine.physics_ticks_per_second / 2.0);
const COUNTER_UPDATE_FRAMERULE : float = 0.35; # hehe
const COUNTER_UPDATE_SLOW : float = 0.7;

# counterss, will update in _process()
var fastest_tick : float = 0;
var framerule_tick : float = 0;
var slow_tick : float = 0;

const BUSINESS_PACKED := preload("res://scenes/Business.tscn");
const CLICK_LABEL_PACKED := preload("res://scenes/FloatingLabel.tscn");


var current_view: View = View.MAIN:
	get:
		return current_view;
	set(value):
		#print('Setting current view from ', views[current_view], ' to ', views[value]);
		if value == current_view:
			pass; # we don't return just in case we somehow didn't update it earlier
			# actually that one was for initial setting heheheha
		current_view = value;
		for key in views:
			if key != value:
				if views[key].has_method('hide_menu'):
					views[key].hide_menu();
			else:
				if views[key].has_method('show_menu'):
					views[key].show_menu();


@onready var main : MainGui = %MainGUI;
@onready var flavour_menu : FlavourMenu = %FlavourMenu;
@onready var tech_tree_menu : TechTreeMenu = %TechTreeMenu;

@onready var businesses_list := main.business_list;
@onready var bank_counter := main.bank_counter;
@onready var ips_counter := main.ips_counter;
@onready var clickme : Clickme = main.clickme;

# probably won't need this anymore
@onready var views : Dictionary = {
	View.MAIN : main,
	View.FLAVOURS : flavour_menu,
	View.TECHS : tech_tree_menu,
};

@onready var bs_arr := Game.bs_arr;
@onready var bs_dict := Game.bs_dict;

var business_nodes: Dictionary;


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Main scene loaded");
	current_view = View.MAIN;
	clickme.clicked.connect(_on_clicked);
	get_window().min_size = Vector2i(1024, 768);
	# no!! should actually only add the unlocked ones
	var previous : Control = null;
	for b in bs_arr:
		var b_node := BUSINESS_PACKED.instantiate();
		b_node.previous = previous;
		b_node.business = b;
		businesses_list.add_child(b_node);
		business_nodes[b.short_name] = b_node;
		previous = b_node;
	EventBus.business_purchased.connect(_on_business_purchased);
	EventBus.upgrade_purchased.connect(_on_upgrade_purchased);
	EventBus.flavour_purchased.connect(_on_flavour_purchased);
	#$MainGUI.process_mode = Node.PROCESS_MODE_DISABLED;
	main.flavours_btn.pressed.connect(func(): current_view = View.FLAVOURS);
	main.techs_btn.pressed.connect(func(): current_view = View.TECHS);
	flavour_menu.exit_button.pressed.connect(func(): current_view = View.MAIN);


# for updating UI stuff (counters etc)
func _process(delta):
	fastest_tick += delta;
	framerule_tick += delta;
	if fastest_tick >= COUNTER_UPDATE_FASTEST:
		fastest_tick = 0.0;
		update_counter();
		update_ips();
		EventBus.update_fastest.emit();
	if framerule_tick >= COUNTER_UPDATE_FRAMERULE:
		framerule_tick = 0.0;
		EventBus.update_framerule.emit();
	if slow_tick >= COUNTER_UPDATE_SLOW:
		slow_tick = 0.0;
		EventBus.update_slow.emit();


# for updating game logic stuff (production etc)
func _physics_process(delta):
	var ips : float = 0;
	for b in bs_arr:
		if b.count > 0:
			var produced : float = b.initial_production;
			
			# and other multipliers as well
			produced *= Game.multipliers["flavours"];
			
			# for example
			produced *= Game.multipliers["businesses"][b.short_name];
			
			b.production = produced;
			
			produced = b.base_produce(delta);
			
			b.production_all_time += produced;
			ips += produced;
			Game.counter_all_time += produced;
			Game.counter += produced;
	Game.ips = ips / delta;
	update_ips();


func update_counter():
	bank_counter.text = Globals.format_num(floorf(Game.counter));


func update_ips():
	ips_counter.text = 'per second: ' + Globals.format_num(Game.ips, 2);


func handle_click():
	var produced : float = Game.get_click_production();
	Game.counter_all_time += produced;
	Game.counter += produced;
	update_counter();
	var pos := get_viewport().get_mouse_position();
	var label := CLICK_LABEL_PACKED.instantiate();
	label.text = Globals.format_num(produced);
	label.position = pos - Vector2(0, 25);
	add_child(label);


func _on_business_purchased(business: Business, amount: int):
	var b_node : PanelContainer = business_nodes[business.short_name];
	business.count += amount;
	var current_price : float = business.price;
	b_node.business.price = floorf(business.initial_price * pow(business.multiplier, b_node.business.count));
	b_node.update();
	var game_b; # ???
	Game.counter -= current_price;


func _on_upgrade_purchased(business: Business, upgrade: Upgrade):
	var id : String = upgrade["short_name"];
	Game.purchase_upgrade(upgrade);
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


func _on_flavour_purchased(f: Flavour):
	print(f.full_name);
	Game.purchase_flavour(f);


func _on_clicked():
	handle_click();


func _on_flavours_btn_pressed():
	current_view = View.FLAVOURS;
	return;
	# don't ask
	var screen_size : Vector2 = (func():
		for c in get_children():
			if c is CanvasItem:
				return c.get_viewport_rect().size;).call();
	var popup : PopupPanel = PopupPanel.new();
	#popup.transient = true;
	#popup.exclusive = true;	
	# popup.visible = true;
	popup.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN;
	popup.size = screen_size;
	popup.popup();
	popup.add_child(load("res://scenes/flavour_menu_test.tscn").instantiate());
	add_child(popup);


func _input(event: InputEvent):
	if event.is_action_pressed('ui_cancel'):
		if current_view != View.MAIN:
			current_view = View.MAIN;
