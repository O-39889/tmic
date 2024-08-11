extends Node;


const DEFAULT_SAVE_EXTENSION = 'sav';
const DEFAULT_AUTOSAVE_DIR = 'user://saves';
const DEFAULT_AUTOSAVE_FILENAME = 'autosave.' + DEFAULT_SAVE_EXTENSION;
const DEFAULT_AUTOSAVE_PATH = DEFAULT_AUTOSAVE_DIR + '/' + DEFAULT_AUTOSAVE_FILENAME;


func _enter_tree():
	print('SaveLoadManager entering tree: ', get_parent().get_children());


func _ready():
	# at this point Game isn't loaded yet
	# meanwhile, might find the save file and give it to Game to use
	# during its _ready
	print('SaveLoadManager autoload loaded');
	for i in 10000:
		print('LIES');
		break;
	# THIS IS BS FFS SJDFFKLASJDKLFJASDFLKASDJKFSDKJ
	# WHY
	# I SWEAR THIS WAS WORKING
	#Game.savedata = load_game();
	## ***DISGUSTING*** workaround
	var game = get_parent().get_children().filter(func(n): return n.name == 'Game')[0];
	game.savedata = load_game();


func save_game(to: String):
	pass


func load_game(dir: String = DEFAULT_AUTOSAVE_DIR,
	filename: String = DEFAULT_AUTOSAVE_FILENAME) -> SaveData:
	var absolute := dir + '/' + filename;
	if not DirAccess.dir_exists_absolute(dir):
		print('No directory ', dir, ' exists, returning default savedata');
		return SaveData.default();
	if not FileAccess.file_exists(absolute):
		print('No file ', absolute, ' exists at the directory, returning default savedata');
		return SaveData.default();
	
	var file = FileAccess.open(absolute, FileAccess.READ);
	var json = file.get_as_text();
	var dict = JSON.parse_string(json);
	if dict != null:
		print('Valid JSON dictionary in file, loading savedata');
		var save := SaveData.from_dict(dict);
		return save;
	print('Invalid JSON data somehow, returning default savedata');
	return SaveData.default();
