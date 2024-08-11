@tool
class_name TechTreeMenu extends Control;


@onready var bounds : Vector2 = $ReferenceRect.size;
@onready var parallax_background : ParallaxBackground = %ParallaxBackground;
@onready var parallax_layer : ParallaxLayer = %ParallaxLayer;
@onready var exit_btn : Button = %Exit;


func _ready():
	parallax_background.visible = self.visible;


func _input(event):
	if not Engine.is_editor_hint():
		if Input.is_action_pressed("mouse_left"):
			if event is InputEventMouseMotion:
				move(event.relative);
		# for zooming in and out
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				pass
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				pass


func move(offset: Vector2):
	var new_pos : Vector2 = (parallax_layer.motion_offset + offset)\
	.clamp(-bounds + get_viewport_rect().size, Vector2.ZERO);
	parallax_layer.motion_offset = new_pos;


func hide_menu():
	parallax_background.visible = false;
	self.visible = false;
	process_mode = Node.PROCESS_MODE_DISABLED;


func show_menu():
	#print('Loading tech tree...');
	parallax_background.visible = true;
	self.visible = true;
	process_mode = Node.PROCESS_MODE_INHERIT;


func _on_visibility_changed():
	#print('Tech tree visibility changed');
	if parallax_background:
		parallax_background.visible = self.visible;
