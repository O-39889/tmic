class_name NewsMessage extends Label;


const SPEED := 200;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x -= SPEED * delta;
	if position.x < -size.x - 10.0:
		queue_free();
		print('Goodbye: ', text);
		print('Goodnight ', [
			'moon of Chernobyl',
			'melted phone',
			'glowing milk',
			'bleeding grandpa\'s eyes',
			[
				'',
				'blocks of ',
				'blocks and blocks of ',
				'blocks and blocks and blocks of ',
				'blocks and blocks and blocks and blocks of ',
			].pick_random() + 'nobody'
		].pick_random());
