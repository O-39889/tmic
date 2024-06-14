@tool
class_name TechNode extends Control

@export var tech_id: String;
@export var descendants: Array[TechNode];
var ancestors: Array[TechNode];


# Called when the node enters the scene tree for the first time.
func _ready():
	for node in descendants:
		node.ancestors.append(self);
	# also should create the connector lines


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		# just draw lines connecting every
		pass
	else:
		# would probably need to manage the real connector objects
		pass
