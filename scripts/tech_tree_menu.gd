# idk why it was tool
class_name TechTreeMenu extends Control;


var nodes : Array[TechNode] = [];

@onready var bounds : Vector2 = $Bounds.size;
@onready var parallax_background : ParallaxBackground = %ParallaxBackground;
@onready var parallax_layer : ParallaxLayer = %ParallaxLayer;
@onready var content : Node2D = %Content;
@onready var exit_btn : Button = %Exit;


func _ready():
	# TODO: center the "camera" when opening the node thingy
	parallax_background.visible = self.visible;
	var nodes_arr := content.get_children().filter(func(n): return n is TechNode);
	nodes_arr.sort_custom(func(t1: TechNode, t2: TechNode): return t1.tech.id < t2.tech.id);
	nodes.assign(nodes_arr);
	# at this point the first pass is already done
	# now...
	# pass  2: set the purchased ones
	for n : TechNode in nodes:
		if n.tech.purchased:
			n.state = TechNode.NodeState.PURCHASED;
	# pass 3: nodes without ancestors or with all purchased ancestors are unlocked
	for n : TechNode in nodes:
		if n.tech.id == 1:
			pass
		if n.state != TechNode.NodeState.PURCHASED:
			if n.ancestors.is_empty() or n.ancestors.all(
				func(ancestor: TechNode):
					return ancestor.state == TechNode.NodeState.PURCHASED):
				n.state = TechNode.NodeState.UNLOCKED;
	for n : TechNode in nodes:
		n.update();


func _input(event):
	if not Engine.is_editor_hint():
		if Input.is_action_pressed("mouse_left"):
			if event is InputEventMouseMotion:
				move(event.relative);
		# for zooming in and out
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP\
			and event.is_pressed():
				pass
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN\
			and event.is_pressed():
				pass


func move(offset: Vector2):
	var new_pos : Vector2 = (parallax_layer.motion_offset + offset)\
	.clamp(-bounds + get_viewport_rect().size, Vector2.ZERO);
	parallax_layer.motion_offset = new_pos;
	if content:
		content.position = new_pos;


func hide_menu():
	parallax_background.visible = false;
	self.visible = false;
	process_mode = Node.PROCESS_MODE_DISABLED;


func show_menu():
	#print('Loading tech tree...');
	parallax_background.visible = true;
	self.visible = true;
	process_mode = Node.PROCESS_MODE_INHERIT;
	for n : TechNode in nodes:
		n.update();


func _on_visibility_changed():
	#print('Tech tree visibility changed');
	if parallax_background:
		parallax_background.visible = self.visible;
