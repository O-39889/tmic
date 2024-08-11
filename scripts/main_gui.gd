class_name MainGui extends VBoxContainer;


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


func hide_menu():
	visible = false;
	process_mode = Node.PROCESS_MODE_DISABLED;


func show_menu():
	visible = true;
	process_mode = Node.PROCESS_MODE_INHERIT;
