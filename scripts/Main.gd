extends Control

# premature optimisation speedrun any%
const LOG_1000 : float = log(1000);

@onready var number_names : PackedStringArray = get_number_names();

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Main scene loaded");
	pass # Replace with function body.


# for updating UI stuff (counters etc)
func _process(delta):
	pass


# for updating game logic stuff (production etc)
func _physics_process(delta):
	pass


func add_thousands_separator(num: int, sep: String = ',') -> String:
	var s := str(num);
	if num < 1000:
		return s;
	var len := s.length();
	for i in range(len - 3, 0, -3):
		s = s.insert(i, sep);
	return s;


func beautify(num: float) -> String:
	var s := "%.3f" % num;
	return s.rstrip("0").rstrip(".");


func format_num(num: float) -> String:
	if is_inf(num):
		return "Infinity";
	if is_nan(num):
		return "NaN";
	if absf(num) < 1_000_000:
		return add_thousands_separator(int(num));
	var log1000 := log(num) / LOG_1000;
	var log_int := int(log1000);
	var number_name := number_names[log_int - 2];
	
	return str(beautify(num / pow(1000, log_int))) + " " + number_name;


func get_number_names() -> PackedStringArray:
	var names : PackedStringArray = [
		"million", "billion", "trillion", "quadrilion", "quintillion",
		"sextillion", "septillion", "octillion", "nonillion",
	];
	const PREFIXES : PackedStringArray = [
		"", "un", "duo", "tre", "quattuor", "quin",
		"sex", # who tf is laughing
		"septen", "octo", "novem",
	];
	const SUFFIXES : PackedStringArray = [
		"decillion", "vigintillion", "trigintillion",
		"quadragintillion", "quinquagintillion", "sexagintillion",
		"septuagintillion", "octogintillion", "nonagintillion",
		"centillion", # actually supposed to be "cenuntillion" etc but i dont care
	];
	for s in SUFFIXES:
		for p in PREFIXES:
			if p + s == "trevigintillion":
				# it just sounds better
				names.append("tresvigintillion");
				continue;
			names.append(p + s);
			if p + s == "uncentillion":
				# anything after that is > 2 ^ 1024
				return names;
	return names;
