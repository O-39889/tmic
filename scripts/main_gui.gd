class_name MainGui extends VBoxContainer;


const BUSINESS_NODE_PACKED := preload("res://scenes/Business.tscn");
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

@onready var prestige_counter : Label = %PrestigeCounterMaybe;

@onready var clickme : Clickme = %ClickMe;

@onready var click_labels : Array[FloatingLabel] = [];

@onready var test_btn : Button = (func():
		var btn = %ResetBtn2;
		btn.pressed.connect(func():
			var savedata = SaveData.default();
			savedata.ic_in_bank = 1.11200094012380e269;
			print(JSON.stringify(savedata.to_dict()));	
		);
		return btn;
		).call()


func _ready():
	clickme.clicked.connect(_on_clickme_clickmed);
	EventBus.update_fastest.connect(update_bank);
	EventBus.update_fastest.connect(update_ips);
	EventBus.update_slow.connect(update_prestige);
	
	var previous_business : BusinessNode = null;
	for b : Business in Game.bs_arr:
		var b_node : BusinessNode = BUSINESS_NODE_PACKED.instantiate() as BusinessNode;
		b_node.previous = previous_business;
		previous_business = b_node;
		b_node.business = b;
		business_list.add_child(b_node);
	
	%SaveBtnTest.pressed.connect(func():
		Game.save_savedata();
		return
		var save_dialog := FileDialog.new();
		save_dialog.file_selected.connect(func(path: String):
			print(path)
			var file = FileAccess.open(path, FileAccess.WRITE_READ);
			print(file);
			file.store_double(Game.counter);
			print(FileAccess.get_open_error());
			);
		save_dialog.access = FileDialog.ACCESS_USERDATA;
		get_parent().add_child(save_dialog);
		save_dialog.position = get_viewport_rect().size / 2;
		save_dialog.show();
		pass);


func update_bank():
	if can_process():
		bank_counter.text = Globals.format_num(Game.counter);


func update_ips():
	if can_process():
		ips_counter.text = 'per second: ' + Globals.format_num(Game.ips, 2);


func update_prestige():
	if can_process():
		var prestige := floorf(pow(Game.counter / 100000000, 1.0 / 3.0));
		prestige_counter.text = 'Prestige: ' + Globals.format_num(prestige);


func hide_menu():
	visible = false;
	process_mode = Node.PROCESS_MODE_DISABLED;


func show_menu():
	visible = true;
	process_mode = Node.PROCESS_MODE_INHERIT;
	update_bank();
	update_ips();
	update_prestige();


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
	
