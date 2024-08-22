class_name NewsTicker extends Panel;


const HEIGHT := 69;
const INTERVAL_SECONDS := 5;

const MSG_PACKED := preload('res://scenes/news_message.tscn');

var msgs : Array[NewsMessage] = [];


func add_label():
	# if you want an unnecessarily complicated solution to your not that rare
	# and quite a minor problem that you encounter with news headlines potentially
	# repeating two (or even more) times in a row, then here it is:
	# instead of an array of strings, have an array elements of which can be
	# EITHER a string or a callable
	# the callable would just apply some transfurmations and then return
	# a required string
	# then, you just put that string or callable as a news ticker property
	# (like with the last level in brickout) and then just each time you
	# pick an element from an array, you remove that element
	var arr := [];
	if false:
		assert(false, "JUST IN CASE THIS IS JUST EXAMPLE CODE NOTHING SHOULD BE EXECUTED IN HERE");
		var fake_last_var = "Survey shows 99% of people prefer other desserts over ice cream; 1 respondent undecided";
		if Game.counter < 1000:
			arr.append_array([
				"Local entrepreneur tries themselves in ice cream business, has little success",
				"A group of raccoons is spotted eating a huge batch of ice cream in the trash in a local neighbourhood",
				(func(): 
					var str = "News: survey shows "\
					+ ("less and less" if randf() < 0.5 else "fewer and fewer")\
					+ " people name ice cream as their favourite ";
					if randf() < 1.0 / 365.25071624375:
						str += "summer";
					else:
						match Time.get_datetime_dict_from_system()['month']:
							12, 1, 2:
								str += "winter";
							3, 4, 5:
								str += "spring";
							6, 7, 8:
								str += "summer";
							9, 10, 11:
								if randf() < 0.5:
									str += "fall";
								else:
									str += "autumn";
					return str + " treat";
					),
					"Survey shows 99% of people prefer other desserts over ice cream; 1 respondent undecided",
					# YOU MADE ME DO THIS
					# JUAN YOU MADE ME DO A 286 LONG LINE
					# BECAUSE OF YOUR STUPID INDENTATION ERRORS
					# AND THIS IS NOT EVEN GONNA BE USED ANYWHERE FFS
					(func(): return "Random obscured new feature in an ice cream-themed incremental video game tested poorly, " + str(randi_range(1, 179)) + " dead in " + ["Kentucky", "Vermont", "Maine", "Ohio", "Arkansas", "Arizona", "Kursk", "Florida", "New Hampshire"].pick_random()),
				]);
			# prolly not gonna work lol
			# unless i move all potential candidate messages
			# to a class property
			arr.erase(fake_last_var);
			var msg = arr.pick_random();
			fake_last_var = msg;
			var lbl : NewsMessage = MSG_PACKED.instantiate() as NewsMessage;
			if msg is String:
				lbl.text = msg;
			elif msg is Callable:
				lbl.text = msg.call();
			else:
				assert(false, "WHAT THE HOOK");
	if Game.counter_all_time < 1000:
		arr.append_array([
			"Local entrepreneur tries themselves in ice cream business, has little success",
			"A group of raccoons is spotted eating a huge batch of ice cream in the trash in a local neighbourhood",
			"News: survey shows " + ("less and less" if randf() < 0.5 else "fewer and fewer") + " people name ice cream as their favourite " + (func():
					if randf() < 1.0 / 13.0:
						return "summer";
					match Time.get_datetime_dict_from_system()['month']:
						1, 2, 12:
							return "winter";
						3, 4, 5:
							return "spring";
						6, 7, 8:
							return "summer";
						9, 10, 11:
							return "autumn";
					).call() + " treat",
			"Survey shows 99% of people prefer other desserts over ice cream; 1 respondent undecided",
			"New study shows ice cream has \"literally no health benefits at all\"",
		]);
	
	if randf() < 0.000125:
		arr.append("Help");
	
	var msg : String = arr.pick_random();
	var lbl := MSG_PACKED.instantiate() as NewsMessage;
	lbl.text = msg;
	lbl.size.y = HEIGHT;
	if msgs.is_empty():
		lbl.position.x = get_viewport_rect().size.x + NewsMessage.SPEED * randf_range(1.0, 2.0);
	else:
		lbl.position.x = msgs[-1].position.x + msgs[-1].size.x + INTERVAL_SECONDS * NewsMessage.SPEED;
	msgs.append(lbl);
	# oh you're BUSY making children?? ffs
	# you remind me of f2820ae0-a0b0-4832-8741-6a4dbfdb9b99
	# however, unlike you, it was unwilling to make children instead for some reason
	# i barely stuffed it into a minecart but then it still kept coming out of it
	# in ridiculous directions so i had to just open for lan with cheats and teleport
	# that mofo in there
	# anyway, the issue is that "parent node is busy setting up children" or something
	# not sure what it means lol
	# but whatever
	#self.add_child(lbl);
	add_child.call_deferred(lbl);
	# actually would be funny if you got a (hidden) achievement
	# for having the same news message appear 3 or 4 times in a row
	lbl.tree_exiting.connect(remove_label_and_check.bind(lbl));


func remove_label_and_check(msg: NewsMessage):
	msgs.erase(msg);
	if msgs.size() <= 2:
		add_label();


func _ready():
	for i in 2:
		add_label();
