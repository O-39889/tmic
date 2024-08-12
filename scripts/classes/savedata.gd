class_name SaveData extends Resource;


## The version of the save file, updated when there are updates to the save system.
@export var version : int = 1;
## The player's name.
@export var player_name : String = 'Player';
## The time (as a UNIX timestamp) when the savefile started.
@export var game_started : float = Time.get_unix_time_from_system();
## The time (as a UNIX timestamp) when the game started after the last reset.
@export var current_run_started : float = self.game_started;
## The time (as a UNIX timestamp) when the game was last saved (for calculating offline production etc).
@export var last_saved : float = self.game_started;

## How many times has the game been reset.
@export var amount_of_resets : int = 0;

## Ice cream currently in bank.
@export var ic_in_bank : float = 0.0;
## Ice cream made in total this run.
@export var ic_this_run : float = 0.0;
## Ice cream made in total on this savefile, including previous runs.
@export var ic_all_time : float = 0.0;

## Ice cream made from clicks this run.
@export var ic_clicked : float = 0.0;
## Ice cream made from clicks in total on this savefile, including previous runs.
@export var ic_clicked_all_time : float = 0.0;
## Total clickme clicks this run.
@export var clicks : int = 0;
## Total clickme clicks all time.
@export var clicks_all_time : int = 0;

## All businesses owned by the player. The key is the string ID of the business,
## and the value is the amount of businesses of that type. Can be omitted if
## there's no businesses of that type purchased.
@export var businesses : Dictionary = {};
## All upgrades purchased by the player. The keys are the string IDs of the
## corresponding businesses; each value in the dictionary is an array of string
## IDs of upgrades for a respective business.
@export var upgrades : Dictionary = {};
## All flavours purchaed by the player. Elements are string IDs of the flavours.
## Vanilla/default flavour doesn't count but whatever.
@export var flavours : Array = ['vanilla'];
## All techs purchased by the player. Elements are string IDs of the techs.
## Doesn't reflect the tech tree order or care about the ancestor-descedant
## relationships in any way.
@export var techs : Array = [];
## The event data.
@export var val : bool = false;


static func default() -> SaveData:
	var save : SaveData = SaveData.new();
	return save;


static func from_dict(dict: Dictionary) -> SaveData:
	var save = SaveData.default();
	if dict.has('version'):
		save.version = dict['version'];
	else:
		printerr('No savedata version detected!');
		
	if dict.has('player_name'):
		save.player_name = dict['player_name'];
	if dict.has('game_started'):
		save.game_started = dict['game_started'];
	if dict.has('current_run_started'):
		save.current_run_started = dict['current_run_started'];
	if dict.has('last_saved'):
		save.last_saved = dict['last_saved'];
	if dict.has('amount_of_resets'):
		save.amount_of_resets = dict['amount_of_resets'];
	if dict.has('ic_in_bank'):
		save.ic_in_bank = dict['ic_in_bank'];
	if dict.has('ic_all_time'):
		save.ic_all_time = dict['ic_all_time'];
	if dict.has('ic_clicked'):
		save.ic_clicked = dict['ic_clicked'];
	if dict.has('ic_clicked_all_time'):
		save.ic_clicked_all_time = dict['ic_clicked_all_time'];
	if dict.has('clicks'):
		save.clicks = dict['clicks'];
	if dict.has('clicks_all_time'):
		save.clicks_all_time = dict['clicks_all_time'];
	if dict.has('businesses'):
		save.businesses = dict['businesses'].duplicate();
	if dict.has('upgrades'):
		save.upgrades = dict['upgrades'].duplicate(true);
	if dict.has('flavours'):
		save.flavours = dict['flavours'].duplicate();
	if dict.has('techs'):
		save.techs = dict['techs'].duplicate();
	return save;


static func to_new_version(old: SaveData) -> SaveData:
	match old.version:
		_:
			return old.duplicate();


func to_dict() -> Dictionary:
	return {
		version = self.version,
		player_name = self.player_name,
		game_started = self.game_started,
		current_run_started = self.current_run_started,
		last_saved = self.last_saved,
		# only used for convenience and doesn't matter when deserializing
		last_saved_str = Time.get_datetime_string_from_unix_time(self.last_saved, true),
		amount_of_resets = self.amount_of_resets,
		ic_in_bank = self.ic_in_bank,
		ic_this_run = self.ic_this_run,
		ic_all_time = self.ic_all_time,
		ic_clicked = self.ic_clicked,
		ic_clicked_all_time = self.ic_clicked_all_time,
		clicks = self.clicks,
		clicks_all_time = self.clicks_all_time,
		businesses = self.businesses.duplicate(),
		upgrades = self.upgrades.duplicate(true),
		flavours = self.flavours.duplicate(),
		techs = self.techs.duplicate(),
	};
