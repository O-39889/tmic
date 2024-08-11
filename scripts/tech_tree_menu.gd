class_name TechTreeMenu extends Control;


@onready var bounds : Vector2 = $ReferenceRect.size;
@onready var player : ParallaxLayer = $ParallaxBackground/ParallaxLayer;
@onready var content : Node2D = $Stuff;


func _input(event):
	if Input.is_action_pressed("mouse_left"):
		if event is InputEventMouseMotion:
			move(event.relative);


func move(offset: Vector2):
	var new_pos : Vector2 = ((player.motion_offset + offset)
	.clamp(-bounds + get_viewport_rect().size, Vector2.ZERO));
	player.motion_offset = new_pos;
	content.position = new_pos;
