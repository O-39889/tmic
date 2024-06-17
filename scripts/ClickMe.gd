extends AspectRatioContainer


signal clicked;


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_mouse_entered():
	modulate = Color.WHITE;


func _on_mouse_exited():
	modulate = Color("#aeaeae")


func _on_click_me_pressed():
	clicked.emit();
