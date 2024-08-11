class_name Clickme extends CenterContainer;


signal clicked(amount: float);


func _on_mouse_entered():
	modulate = Color.WHITE;


func _on_mouse_exited():
	modulate = Color("#aeaeae");


func _on_click_me_pressed():
	clicked.emit(Game.get_click_production());
