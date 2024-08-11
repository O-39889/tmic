class_name MainGui extends VBoxContainer;


const CLICK_LABEL_PACKED := preload("res://scenes/FloatingLabel.tscn");


@onready var options_btn : Button = %OptionsBtn;
@onready var stats_btn : Button = %StatsBtn;
@onready var reset_btn : Button = %ResetBtn;

@onready var flavours_btn : Button = %FlavoursBtn;
@onready var techs_btn : Button = %TechsBtn;
@onready var tech_shortcuts : HFlowContainer = %TechShortcuts;

@onready var business_list : VBoxContainer = %BusinessesList;
@onready var bank_counter : Label = %BankCounter;
@onready var ips_counter : Label = %IpsCounter;

@onready var prestige_counter : Label = %PrestigeCounter;

@onready var clickme : Clickme = %ClickMe;

@onready var click_labels : Array[FloatingLabel] = [];


func _ready():
	clickme.clicked.connect(_on_clickme_clickmed);
	EventBus.update_fastest.connect(update_bank);
	EventBus.update_fastest.connect(update_ips);
	EventBus.update_slow.connect(update_prestige);


func update_bank():
	bank_counter.text = Globals.format_num(Game.counter);


func update_ips():
	ips_counter.text = 'per second: ' + Globals.format_num(Game.ips, 2);


func update_prestige():
	pass


func hide_menu():
	visible = false;
	process_mode = Node.PROCESS_MODE_DISABLED;


func show_menu():
	visible = true;
	process_mode = Node.PROCESS_MODE_INHERIT;


func _process(delta: float):
	update_ips();


func _on_clickme_clickmed(amount: float):
	update_bank();
	var pos := get_viewport().get_mouse_position();
	var label := CLICK_LABEL_PACKED.instantiate();
	label.text = Globals.format_num(amount);
	label.position = pos - Vector2(0, 25);
	add_sibling(label);
	click_labels.append(label);
	label.tree_exiting.connect(func(): click_labels.erase(label));
	
