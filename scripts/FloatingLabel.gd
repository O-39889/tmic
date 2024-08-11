class_name FloatingLabel extends Label;

const SPEED = 42.6969696969696969;
const FADE_TIME = 3;
@onready var timer := get_tree().create_timer(FADE_TIME);


# Called when the node enters the scene tree for the first time.
func _ready():
	timer.timeout.connect(func(): self.queue_free());


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y -= delta * SPEED;
	# i think it should work this way
	modulate.a -= delta / FADE_TIME;
