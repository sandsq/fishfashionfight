extends Resource
class_name Inventory

signal fishes_changed(indexes) ## array of positions that changed

@export var fish_parts: Array[Resource] = [
	null, null, null, null, null, null, null, null, null
]

var ufishtest = preload("res://fish/ufish.tres")
var drag_data = null

func _init():
	assert(GS.INVENTORY_SIZE == fish_parts.size())

	
func add_to_inventory():
	var ufish_parts = ufishtest.make_fish_parts()
	for i in range(fish_parts.size()):
		fish_parts[i] = ufish_parts[i]
		
	
func get_fish_parts():
	return fish_parts


func remove_fish_parts(indexes):
	var previous_items: Array[Resource]
	for i in indexes:
		previous_items.append(fish_parts[i])
		fish_parts[i] = null
	emit_signal("fishes_changed", indexes)
	return previous_items
	
