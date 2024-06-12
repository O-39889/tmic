extends Node

# premature optimisation speedrun any%
const LOG_1000 : float = log(1000);

@onready var number_names : PackedStringArray = get_number_names();


func _ready():
	print("Globals autoload loaded");


func add_thousands_separator(num: float, sep: String = ',', decimals: int = 0) -> String:
	var s := beautify(num, decimals);
	# number less than 1000 won't need thousand seps
	if num < 1000:
		return s;
	var split := s.split('.');
	var len := split[0].length();
	
	for i in range(len - 3, 0, -3):
		split[0] = split[0].insert(i, sep);
	if split.size() == 1:
		return split[0];
	else:
		return split[0] + '.' + split[1];


func beautify(num: float, decimals: int = 3) -> String:
	# ?????
	return String.num(num, decimals);


# decimals is for non-integer values less than 1 million
func format_num(num: float, decimals: int = 0) -> String:
	if is_inf(num):
		return "Infinity";
	if is_nan(num):
		return "NaN";
	if absf(num) < 1_000_000:
		return add_thousands_separator(num, ',', decimals);
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
