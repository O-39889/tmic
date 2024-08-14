@tool
class_name TechNode extends TextureButton;


enum NodeState {
	HIDDEN,
	UNLOCKED,
	PURCHASED,
};

'''
Will need to do basically multiple passes, and also probably both in here
and the tech tree code.
Basically:
	1) Assign ancestors arrays everywhere, this is done in _ready() methods of nodes
	so we can work in _ready() in the tree, already assuming that the ancestors are set
	2) Set the purchased nodes into PURCHASED state, they don't change after that
	3) Third pass: set all nodes that either don't have ancestors or only have PURCHASED
	ancestors and aren't purchased themselves as UNLOCKED
	(that one is both for affordable and unaffordable ones)
	4) All other nodes remain HIDDEN
'''

const SIZE := 50.0;


@export var tech_id : StringName;
@export var descendants : Array[TechNode] = [];

# assigned from the node's ancestors
var ancestors : Array[TechNode] = [];
var state : NodeState = NodeState.HIDDEN:
	get:
		return state;
	set(value):
		state = value;
		update();
# set in _ready()
var tech : Tech;

@onready var ___name := name;

func _ready():
	if not Engine.is_editor_hint():
		assert(Game.techs_dict.has(tech_id), 'No tech with string ID ' + tech_id + ' found for node ' + str(self));
		tech = Game.techs_dict[tech_id];
		print();
		for tn in descendants:
			tn.ancestors.append(self);
	size = Vector2(SIZE, SIZE);
	update();
	tooltip_text = tech.full_name + '\n' + tech.description;


func _process(delta):
	if Engine.is_editor_hint():
		queue_redraw();
	if not Engine.is_editor_hint():
		if state == NodeState.UNLOCKED:
			disabled = Game.counter < tech.price;
		else:
			disabled = state == NodeState.HIDDEN;


func center() -> Vector2:
	return self.position + Vector2(SIZE / 2, SIZE / 2);


# Called on descendant nodes after buying an ancestor node tech
func update_state():
	if state == NodeState.PURCHASED:
		return;
	if ancestors.all(func(n: TechNode): return n.state == NodeState.PURCHASED):
		state = NodeState.UNLOCKED;


func update():
	if not Engine.is_editor_hint():
		visible = state != NodeState.HIDDEN;
		if state == NodeState.HIDDEN:
			# don't need to do that though
			# bc a fun thing is that it doesn't actually
			# receive input when invisible haha
			disabled = true;
		if state == NodeState.UNLOCKED:
			disabled = Game.counter < tech.price;
		elif state == NodeState.PURCHASED:
			disabled = false;
			modulate = Color.LIME;
	queue_redraw();


func _draw():
	if Engine.is_editor_hint():
		draw_string(ThemeDB.fallback_font, Vector2(),
		tech_id, HORIZONTAL_ALIGNMENT_CENTER, -1, 24);
	if descendants == null or descendants.size() == 0:
		return;
	for d in descendants:
		if d and (Engine.is_editor_hint() or
			d.state != NodeState.HIDDEN):
			draw_dashed_line(self.center() - self.position, d.center() - self.position,
			Color.GRAY, 10.0, 20, false);


func _on_pressed():
	if state == NodeState.UNLOCKED and not disabled:
		Game.purchase_tech(tech);
		state = NodeState.PURCHASED;
		update();
		for d in descendants:
			d.update_state();
