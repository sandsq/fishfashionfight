extends CenterContainer

signal can_be_dropped_signal

var inventory = preload("res://inventory/inventory.tres")
var associated_fish_part: FishPart
var icon_preview: TextureRect
var should_update_preview = false
var update_counter = 0

@onready var fish_part_texture_rect = $FishPartTextureRect

func _process(_delta):
	if should_update_preview:
		update_counter += 1
		if update_counter == 2:
			icon_preview.visible = true
			should_update_preview = false
			update_counter = 0

func display_fish_part(fish_part):
	if fish_part is FishPart:
		fish_part_texture_rect.texture = fish_part.texture
		associated_fish_part = fish_part
	else:
		fish_part_texture_rect.texture = load("res://assets/inventory_placeholder.png")


func _get_drag_data(_position):
	var fish_part_index = get_index()
	print("drag data index of fish part %s" % fish_part_index)
	if not associated_fish_part is FishPart:
		return
	var fish = associated_fish_part.get_parent_fish()
	print("drag data parent fish %s" % fish)
	var data = {}
	if fish is Entity:
		var relative_indexes = fish.get_arrangement_indexes()
		var absolute_indexes = fish.get_absolute_arrangement_indexes()
		print("absolute indexes when getting drag data %s" % [absolute_indexes])
		inventory.remove_fish_parts(absolute_indexes)
		
		
		icon_preview = TextureRect.new()
		icon_preview.texture = fish.texture
		icon_preview.visible = false
		#icon_preview.mouse_filter = MOUSE_FILTER_PASS
		var drag_preview = Control.new() # TextureRect.new()
		drag_preview.add_child(icon_preview)
		#drag_preview.mouse_filter = MOUSE_FILTER_PASS
		should_update_preview = true
		set_drag_preview(drag_preview)
		
		
		data.fish = fish
		data.fish_absolute_indexes = absolute_indexes
		data.fish_relative_indexes = relative_indexes
		
	inventory.drag_data = data
	return data

func _can_drop_data(_position, data):
	if data is Dictionary and data.has("fish"):
		var my_fish_part_index = get_index()
	
		#var fish_to_drop = data.fish
		#var fish_to_drop_abs_inds = data.fish_absolute_indexes
		var fish_to_drop_rel_inds = data.fish_relative_indexes
		
		var new_abs_inds = fish_to_drop_rel_inds.map(
				func(i): return i + my_fish_part_index)
		
		#print("calculating if something can be dropped here %s" 
				#% [new_abs_inds])
			
		for ind in new_abs_inds:
			if ind >= GS.INVENTORY_SIZE:
				emit_signal("can_be_dropped_signal", false)
				return false
				
			var potential_fish_part = inventory.get_fish_parts()[ind]
			if potential_fish_part is FishPart:
				var potential_fish = potential_fish_part.get_parent_fish()
				var potential_fish_abs_inds = \
						potential_fish.get_absolute_arrangement_indexes()
				#print("trying to drop into %s which already has a fish"
						#% [potential_fish_abs_inds])
				for ind2 in potential_fish_abs_inds:
					if new_abs_inds.has(ind2):
						emit_signal("can_be_dropped_signal", false)
						return false
		emit_signal("can_be_dropped_signal", true)	
		return true
	else:
		emit_signal("can_be_dropped_signal", false)
		return false


	
func _drop_data(_position, data):
	var my_fish_part_index = get_index()
	#var my_fish_part = inventory.fish_parts[my_fish_part_index]
	
	var relative_indexes_to_be_dropped = data.fish_relative_indexes
	var fish_to_be_dropped = data.fish
	var fish_parts_to_be_dropped = fish_to_be_dropped.make_fish_parts()
	
	var new_absolute_indexes_to_be_dropped: Array[int] = []
	for ind in relative_indexes_to_be_dropped:
		new_absolute_indexes_to_be_dropped.append(ind + my_fish_part_index)
	
	#if my_fish_part is FishPart:
		#var my_fish = my_fish_part.get_parent_fish()
	
	fish_to_be_dropped.set_absolute_arrangement_indexes(
			new_absolute_indexes_to_be_dropped)
			
	inventory.set_fish_parts(
			new_absolute_indexes_to_be_dropped, fish_parts_to_be_dropped)
	
	print("after dropping, new inventory %s" % [inventory.get_fish_parts()])
	
	inventory.drag_data = null
		
		
