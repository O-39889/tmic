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


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Main scene loaded");
	current_view = View.MAIN;
	clickme.clicked.connect(_on_clickmed);
	get_window().min_size = Vector2i(1024, 768);
	# no!! should actually only add the unlocked ones
	var previous : Control = null;
	
	EventBus.business_purchased.connect(_on_business_purchased);
	EventBus.upgrade_purchased.connect(_on_upgrade_purchased);
	EventBus.flavour_purchased.connect(_on_flavour_purchased);
	# oh wait i see
	# so it actually only handles purchasing stuff through Main for some reason
	EventBus.tech_purchased.connect(_on_tech_purchased);
	
	EventBus.update_slow.connect(_on_update_slow);
	
	main.flavours_btn.pressed.connect(func(): current_view = View.FLAVOURS);
	main.techs_btn.pressed.connect(func(): current_view = View.TECHS);
	
	flavour_menu.exit_button.pressed.connect(func(): current_view = View.MAIN);
	
	tech_tree_menu.exit_btn.pressed.connect(func(): current_view = View.MAIN);


# for updating UI stuff (counters etc)
func _process(delta):
	fastest_tick += delta;
	framerule_tick += delta;
	slow_tick += delta;
	if fastest_tick >= COUNTER_UPDATE_FASTEST:
		fastest_tick = 0.0;
		EventBus.update_fastest.emit();
	if framerule_tick >= COUNTER_UPDATE_FRAMERULE:
		framerule_tick = 0.0;
		EventBus.update_framerule.emit();
	if slow_tick >= COUNTER_UPDATE_SLOW:
		slow_tick = 0.0;
		EventBus.update_slow.emit();


# for updating game logic stuff (production etc)
func _physics_process(delta):
	Game.production_tick(delta);


func handle_click(amount: float):
	Game.counter_all_time += amount;
	Game.counter += amount;
	Game.clicks += 1;
	Game.clicks_all_time += 1;
	Game.ic_clicked += amount;
	Game.ic_clicked_all_time += amount;


func _on_business_purchased(business: Business, amount: int):
	if Game.counter >= business.price:
		Game.purchase_business(business, 1);


func _on_upgrade_purchased(business: Business, upgrade: Upgrade):
	if Game.counter >= upgrade.price:
		Game.purchase_upgrade(upgrade);


func _on_flavour_purchased(f: Flavour):
	if Game.counter >= f.price:
		Game.purchase_flavour(f);


func _on_tech_purchased(t: Tech):
	if Game.counter >= t.price:
		Game.purchase_tech(t);


func _on_clickmed(amount: float):
	handle_click(amount);


func _on_update_slow():
	if Game.counter >= 1.0:
		get_window().title = '[' + Globals.format_num(Game.counter) + ' ice cream] ' + 'TMIC';


func _input(event: InputEvent):
	if event.is_action_pressed('ui_cancel'):
		if current_view != View.MAIN:
			current_view = View.MAIN;
	if event.is_action_pressed('f_1'):
		if current_view != View.MAIN:
			current_view = View.MAIN;
	if event.is_action_pressed('f_2'):
		if current_view != View.FLAVOURS:
			current_view = View.FLAVOURS;
	if event.is_action_pressed('f_3'):
		if current_view != View.TECHS:
			current_view = View.TECHS;
	if event.is_action_pressed('save_trigger'):
		print('Saving!');
