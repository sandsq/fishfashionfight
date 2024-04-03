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
	print("index %s" % fish_part_index)
	var fish = associated_fish_part.get_parent_fish()
	print("parent fish %s" % fish)
	var data = {}
	if fish is Entity:
		var affected_indexes = fish.get_arrangement_indexes()
		print("affected indexes %s" % [affected_indexes])
		
		var drag_preview = TextureRect.new()
		drag_preview.texture = fish.texture
		set_drag_preview(drag_preview)
		
		inventory.remove_fish_parts(affected_indexes)
	return data

func _can_drop_data(_position, data):
	return true
	
func _drop_data(_position, data):
	pass
