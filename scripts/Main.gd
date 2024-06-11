extends Control

# premature optimisation speedrun any%
const LOG_1000 : float = log(1000);
const COUNTER_UPDATE_FASTEST : float = 1 / 15;
const COUNTER_UPDATE_FRAMERULE : float = 0.35; # hehe
const COUNTER_UPDATE_SLOW : float = 0.7;

var fastest_tick : float = 0;

@onready var FPS : int = Engine.physics_ticks_per_second;


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Main scene loaded");
	pass # Replace with function body.


# for updating UI stuff (counters etc)
func _process(delta):
	fastest_tick += delta;
	if fastest_tick >= COUNTER_UPDATE_FASTEST:
		$TestLbl.text = Globals.format_num(Game.counter);
		fastest_tick = 0;
	pass


# for updating game logic stuff (production etc)
func _physics_process(delta):
	for b in Game.businesses:
		if b["count"] > 0:
			var produced : float = b["count"] * b["production"] * delta;
			Game.counter += produced;
			b["production_all_time"] += produced;
	pass
