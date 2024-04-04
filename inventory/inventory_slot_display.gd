extends CenterContainer

var inventory = preload("res://inventory/inventory.tres")
var associated_fish_part: FishPart

@onready var fish_part_texture_rect = $FishPartTextureRect

func display_fish_part(fish_part):
	if fish_part is FishPart:
		fish_part_texture_rect.texture = fish_part.texture
		associated_fish_part = fish_part
	else:
		fish_part_texture_rect.texture = load("res://assets/inventory_placeholder.png")


func _get_drag_data(_position):
	var fish_part_index = get_index()
	print("drag data index of fish part %s" % fish_part_index)
	var fish = associated_fish_part.get_parent_fish()
	print("drag data parent fish %s" % fish)
	var data = {}
	if fish is Entity:
		var relative_indexes = fish.get_arrangement_indexes()
		var absolute_indexes = fish.get_absolute_arrangement_indexes()
		print("absolute indexes when getting drag data %s" % [absolute_indexes])
		
		data.fish = fish
		data.fish_absolute_indexes = absolute_indexes
		data.fish_relative_indexes = relative_indexes
		
		var drag_preview = TextureRect.new()
		drag_preview.texture = fish.texture
		set_drag_preview(drag_preview)
		inventory.remove_fish_parts(absolute_indexes)
	return data

func _can_drop_data(_position, data):
	if data is Dictionary and data.has("fish"):
		var my_fish_part_index = get_index()
		
		var fish_to_drop = data.fish
		var fish_to_drop_abs_inds = data.fish_absolute_indexes
		var fish_to_drop_rel_inds = data.fish_relative_indexes
		
		var new_abs_inds = fish_to_drop_rel_inds.map(
				func(i): return i + my_fish_part_index)
		print("calculating if these indexes can be dropped %s" % [new_abs_inds])
		for ind in new_abs_inds:
			if ind >= GS.INVENTORY_SIZE:
				return false
		return true
	else:
		return false
	
func _drop_data(_position, data):
	var my_fish_part_index = get_index()
	var my_fish_part = inventory.fish_parts[my_fish_part_index]
	
	var relative_indexes_to_be_dropped = data.fish_relative_indexes
	var fish_to_be_dropped = data.fish
	var fish_parts_to_be_dropped = fish_to_be_dropped.make_fish_parts()
	
	var new_absolute_indexes_to_be_dropped: Array[int] = []
	for ind in relative_indexes_to_be_dropped:
		new_absolute_indexes_to_be_dropped.append(ind + my_fish_part_index)
	
	if my_fish_part is FishPart:
		var my_fish = my_fish_part.get_parent_fish()
	
	fish_to_be_dropped.set_absolute_arrangement_indexes(
			new_absolute_indexes_to_be_dropped)
			
	inventory.set_fish_parts(
			new_absolute_indexes_to_be_dropped, fish_parts_to_be_dropped)
	print("need to handles the swap case still")
		
	inventory.drag_data = null
		
