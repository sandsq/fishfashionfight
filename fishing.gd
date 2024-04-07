extends Node2D


signal timing_round_finished
signal remaining_fish_allowed_changed
signal fishing_finished

const timing_bar_size = Vector2(4, 25)
const x_offset = 63 ## this is the center of the timing bar, consider it x=0
const timing_bar_y_offset = 24
const fishing_bar_size = Vector2(576, 56)
const fishing_bar_global_pos = Vector2(64, 24)
const right_distance = fishing_bar_size.x - x_offset


@export var timing_seconds = 1.0
@export var fishing_rod: Line2D

var InventoryContainer = preload("res://inventory/inventory_container.tscn")
var InventoryDisplay = preload("res://inventory/inventory_display.tscn")
var Inventory = preload("res://inventory/inventory.tscn")
var Synergy = preload("res://synergy.tscn")
## does not immediately become re-enabled after timing bar is stopped because have to process getting a fish
var timing_bar_can_be_started = true
var timing_bar_is_moving_right = false
var timing_bar_is_moving_left = false
var current_tween: Tween
var timing_bar_ghost: ColorRect
var timing_bar_reached: Vector2 = Vector2.ZERO
var casting_position: float ## this is the global x position of where the fishing line should go
var rng = RandomNumberGenerator.new()
var OneByOne = preload("res://fish/one_by_one.tscn")
var OneByTwo = preload("res://fish/one_by_two.tscn")
var TwoByOne = preload("res://fish/two_by_one.tscn")
var SmallL = preload("res://fish/small_l.tscn")
var UFish = preload("res://fish/u_fish.tscn")
var available_fish = [[OneByOne, OneByTwo], [SmallL, TwoByOne], [UFish]]
var inventory = null
var input_allowed = true
var hit_was_accurate = false

@onready var fishing_bar = $FishingBar
@onready var timing_bar = $FishingBar/TimingBar
@onready var good_margin = $FishingBar/GoodMargin
@onready var character = $Character
@onready var max_fish_allowed = character.character_stats.max_fish_allowed
@onready var remaining_fish_allowed = max_fish_allowed:
	set(new_value):
		remaining_fish_allowed = new_value
		emit_signal("remaining_fish_allowed_changed")
		if remaining_fish_allowed <= 0:
			emit_signal("fishing_finished")
@onready var info_label = $InfoLabel
@onready var inventory_display = InventoryDisplay.instantiate()
@onready var fish_remaining_label = $FishRemainingLabel


func _ready():
	add_child(inventory_display)
	inventory_display.scale = Vector2(0.5, 0.5)
	inventory_display.global_position = Vector2(8, 128)
	inventory = inventory_display.inventory
	inventory.fishes_changed.connect(inventory_display._on_fishes_changed)
	inventory.adding_failed.connect(_on_adding_failed)
	rng.seed = hash("fff")
	fishing_bar.size = fishing_bar_size
	fishing_bar.global_position = fishing_bar_global_pos
	timing_bar.size = timing_bar_size
	good_margin.position = Vector2(x_offset - good_margin.size.x / 2.0, 0)
	self.timing_round_finished.connect(roll_fish)
	self.remaining_fish_allowed_changed.connect(_update_remaining_fish)
	self.fishing_finished.connect(_process_fishing_finished)
	character.weapon.visible = false
	character.hp_label.visible = false
	character.damage_label.visible = false
	fish_remaining_label.text = "%s / %s" % [remaining_fish_allowed, max_fish_allowed]
	reset_timing_state()

func _process(_delta):
	if input_allowed:
		if Input.is_action_just_pressed("ui_accept"):
			if timing_bar_can_be_started:
				start_timing_bar()
			elif timing_bar_is_moving_right:
				reverse_timing_bar()
			elif timing_bar_is_moving_left:
				stop_timing_bar()
		

func reset_timing_state():
	timing_bar.position = Vector2(x_offset - timing_bar_size.x / 2.0, 
			timing_bar_y_offset)
	if timing_bar_ghost != null:
		fishing_bar.remove_child(timing_bar_ghost)

func start_timing_bar():
	timing_bar_can_be_started = false
	timing_bar_is_moving_right = true
	if current_tween is Tween:
		current_tween.stop()
	var start_pos = timing_bar.position
	var tween = create_tween()
	current_tween = tween
	tween.finished.connect(process_timing_bar_moving_right_finished)
	tween.tween_property(timing_bar, "position", 
			start_pos + Vector2(right_distance, 0), timing_seconds)
	tween.play()

func reverse_timing_bar():
	timing_bar_is_moving_right = false
	timing_bar_is_moving_left = true
	
	timing_bar_ghost = timing_bar.duplicate()
	timing_bar_ghost.modulate.a = 0.5
	fishing_bar.add_child(timing_bar_ghost)
	
	if current_tween is Tween:
		current_tween.stop()
	var reached_pos = timing_bar.position
	timing_bar_reached = reached_pos
	
	var tween = create_tween()
	current_tween = tween
	tween.finished.connect(process_timing_bar_moving_left_finished)
	tween.tween_property(timing_bar, "position", 
			Vector2(0, timing_bar_y_offset), 
			timing_seconds * reached_pos.x / right_distance)
	tween.play()
	
func stop_timing_bar():
	timing_bar_is_moving_left = false
	if current_tween is Tween:
		current_tween.stop()
	process_timing_bar_hit()
	
	
func process_timing_bar_hit():
	print("hit good margin at %s" % [timing_bar.position])
	if (
			timing_bar.position.x + timing_bar.size.x 
			>= good_margin.position.x
			and timing_bar.position.x 
			<= good_margin.position.x + good_margin.size.x
	):
		var fishing_accuracy = character.character_stats.fishing_accuracy
		var a = _calculate_casting_position_from_accuracy(
				1.0 - fishing_accuracy, 1.0 + fishing_accuracy)
		var rolled_accuracy = a[0]
		casting_position = a[1]
		print("\thit was accurate, accuracy %s, final pos %s" 
				% [rolled_accuracy, casting_position])
		info_label.text = "Accurate hit, randomness factor %s, distance %s" % [snapped(rolled_accuracy, 0.1), round(casting_position)]
		hit_was_accurate = true
	elif timing_bar.position.x + timing_bar.size.x < good_margin.position.x:
		var undershot_percentage = (x_offset - (good_margin.position.x \
				- (timing_bar.position.x + timing_bar.size.x))) \
				/ right_distance
		var fishing_inaccuracy = character.character_stats.fishing_inaccuracy
		var a = _calculate_casting_position_from_accuracy(
				1.0 - fishing_inaccuracy - undershot_percentage, 1.0)
		var rolled_inaccuracy = a[0]
		casting_position = a[1]
		print("\thit undershot (left) by %s, added inaccuracy %s, final pos %s" 
				% [undershot_percentage, rolled_inaccuracy, casting_position])
		info_label.text = "Undershot, randomness factor %s, distance %s" % [snapped(rolled_inaccuracy, 0.1), round(casting_position)]
	elif timing_bar.position.x > good_margin.position.x + good_margin.size.x:
		var overshot_percentage = (timing_bar.position.x - 
				(good_margin.position.x + good_margin.size.x)) / right_distance
		var fishing_inaccuracy = character.character_stats.fishing_inaccuracy
		var a = _calculate_casting_position_from_accuracy(
				1.0, 1.0 + fishing_inaccuracy + overshot_percentage)
		var rolled_inaccuracy = a[0]
		casting_position = a[1]
		print("\thit overshot (right) by %s, inaccuracy %s, final pos %s" 
				% [overshot_percentage, rolled_inaccuracy, casting_position])
		info_label.text = "Overshot, randomness factor %s, distance %s" % [snapped(rolled_inaccuracy, 0.1), round(casting_position)]
		
	emit_signal("timing_round_finished")

func process_timing_bar_moving_right_finished():
	timing_bar_ghost = timing_bar.duplicate()
	timing_bar_ghost.modulate.a = 0.5
	fishing_bar.add_child(timing_bar_ghost)
	var rolled_inaccuracy = rng.randf_range(0.0, 1.0)
	casting_position = x_offset + right_distance * rolled_inaccuracy
	print("\trandom inaccuracy %s, final pos %s" 
			% [rolled_inaccuracy, casting_position])
	info_label.text = "Random cast, randomness factor %s, distance %s" % [snapped(rolled_inaccuracy, 0.1), round(casting_position)]
	emit_signal("timing_round_finished")
	
func process_timing_bar_moving_left_finished():
	#timing_bar_ghost = timing_bar.duplicate()
	#timing_bar_ghost.modulate.a = 0.5
	#fishing_bar.add_child(timing_bar_ghost)
	var a = _calculate_casting_position_from_accuracy(
				0.0, 1.0)
	var rolled_inaccuracy = a[0]
	casting_position = a[1]
	print("\tleft end, extreme undershoot %s, final pos %s" 
			% [rolled_inaccuracy, casting_position])
	info_label.text = "Extreme potential undershoot, randomness factor %s, distance %s" % [snapped(rolled_inaccuracy, 0.1), round(casting_position)]
	emit_signal("timing_round_finished")

func roll_fish(cast_duration = 0.5):
	var fishing_line_start = fishing_rod.get_point_position(1)
	var fishing_line_end = Vector2(casting_position, 320)
	var fishing_line = Line2D.new()
	fishing_line.default_color = Color(0.8, 0.7, 0.7, 1.0)
	fishing_line.width = 2.5
	fishing_line.add_point(fishing_line_start)
	fishing_line.add_point(fishing_line_start)
	add_child(fishing_line)
	var final_points = PackedVector2Array([fishing_line_start, fishing_line_end])
	var tween = create_tween()
	tween.tween_property(fishing_line, "points", final_points, cast_duration)
	input_allowed = false
	tween.play()
	await tween.finished
	var fish_size_index = min(floor(((casting_position - fishing_bar_global_pos.x) / fishing_bar_size.x) * available_fish.size()), available_fish.size() - 1) # exact dimensions are annoying to keep track of because of things with thickness, timing bar offset, etc., so just use this hack
	var fish_size_options = available_fish[fish_size_index]
	var fish_size_options_index = randi_range(0, fish_size_options.size() - 1)
	var chosen_fish = fish_size_options[fish_size_options_index].instantiate()
	print("selecting fish size index %s, fish index inside that size %s, choosing fish %s" % [fish_size_index, fish_size_options_index, chosen_fish])
	var fish_sprite = Sprite2D.new()
	fish_sprite.global_position = fishing_line.get_point_position(1)
	fish_sprite.texture = chosen_fish.texture
	fishing_line.add_child(fish_sprite)
	var tween_line_back = create_tween()
	var back_points = PackedVector2Array([fishing_line_start, fishing_line_start])
	tween_line_back.tween_property(fishing_line, "points", back_points, 2 * cast_duration)
	var tween_fish_back = create_tween()
	tween_fish_back.tween_property(fish_sprite, "position", fishing_line_start, 2 * cast_duration)
	tween_line_back.play()
	tween_fish_back.play()
	await tween_fish_back.finished
	
	fishing_line.remove_child(fish_sprite)
	
	var synergy = null
	#var fish_part_synergy = -1
	#var fish_part_synergy_side = -1
	#func add_fish_to_inventory(fish_to_add, synergy, fish_part_synergy_target: int, fish_part_synergy_side: int):
	if hit_was_accurate:
		synergy = Synergy.instantiate()
		if chosen_fish.name == "SmallL":
			synergy.synergy_data = {
					"lifesteal_amount": 0.5
			}
		else:
			synergy.synergy_data = {
					"damage_boost": snapped(rng.randf_range(1.5, 4), 0.5)
			}
	
	
	# technically should do this while reeling back so that computation
	# time of fitting into inventory happens during the reel back
	var fish_placed = inventory.add_fish_to_inventory(chosen_fish, synergy)
	
	reset_timing_state()
	if fish_placed:
		remaining_fish_allowed -= 1
	input_allowed = true
	timing_bar_can_be_started = true
	hit_was_accurate = false

func proceed_to_fashion_scene():
	var new_scene = InventoryContainer.instantiate()
	print("inventory right before switching to fashion scene %s" 
			% [inventory])
	get_tree().root.add_child(new_scene)
	#new_scene.call_deferred("remove_child", new_scene.player_display)
	new_scene.player_display.queue_free()
	inventory_display.global_position = Vector2(2, 2)
	inventory_display.scale = Vector2(2.0, 2.0)
	remove_child(inventory_display)
	new_scene.add_child(inventory_display)
	new_scene.player_display = inventory_display
	new_scene.player_display.received_hover_signal_from_slot.connect(
			new_scene._change_info)
	print("in proceed to fashion scene function, if synergies don't activate may need to manually update inventory display")
	#new_scene.player_display.update_inventory_display()
	
	self.visible = false
	
	
func _calculate_casting_position_from_accuracy(lower_bound, upper_bound):
	var rolled_accuracy = rng.randf_range(lower_bound, upper_bound)
	var new_position = fishing_bar_global_pos.x + clamp(timing_bar_ghost.position.x * rolled_accuracy,
			x_offset, fishing_bar.size.x)
	return [rolled_accuracy, new_position]

func _on_adding_failed():
	print("adding failed message?")
	info_label.text = "couldn't add fish to inventory due to space"
	await get_tree().create_timer(2.0).timeout
	info_label.text = ""

func _update_remaining_fish():
	fish_remaining_label.text = "%s / %s" % [remaining_fish_allowed, max_fish_allowed]

func _process_fishing_finished():
	proceed_to_fashion_scene()


func _on_finish_fishing_button_pressed():
	proceed_to_fashion_scene()
