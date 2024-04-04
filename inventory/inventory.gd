extends Resource
class_name Inventory

signal fishes_changed(indexes) ## array of positions that changed

@export var fish_parts: Array[Resource] = [
	null, null, null, null, null, 
	null, null, null, null, null, 
	null, null, null, null, null, 
	null, null, null, null, null, 
	null, null, null, null, null
]

var ufishtest = preload("res://fish/ufish.tres")
var onebytwofish = preload("res://fish/onebytwofish.tres")
var twobyonefish = preload("res://fish/twobyonefish.tres")
var onebyonefish = preload("res://fish/onebyone.tres")

	
func add_to_inventory():
	var ufish_parts = ufishtest.make_fish_parts()
	var ufish_parts_abs_inds = ufishtest.get_absolute_arrangement_indexes()
	print("adding ufish parts %s at abs inds %s" % [ufish_parts, ufish_parts_abs_inds])
	var current_ind = 0
	for part_ind in ufish_parts_abs_inds:
		print("adding the %s th ufish part to inventory slot %s" % [current_ind, part_ind])
		fish_parts[part_ind] = ufish_parts[current_ind]
		current_ind += 1
	
	var fish1 = onebytwofish
	var fish2 = onebytwofish.duplicate()
	var arr: Array[int] = []
	arr.append(3)
	arr.append(4)
	var arr2: Array[int] = []
	arr2.append(15)
	arr2.append(16)
	fish1.set_absolute_arrangement_indexes(arr)
	fish2.set_absolute_arrangement_indexes(arr2)
	var fish_parts1x2 = fish1.make_fish_parts()
	var fish_parts1x2_2 = fish2.make_fish_parts()
	fish_parts[3] = fish_parts1x2[0]
	fish_parts[4] = fish_parts1x2[1]
	fish_parts[15] = fish_parts1x2_2[0]
	fish_parts[16] = fish_parts1x2_2[1]
	
	var fish3 = twobyonefish
	var arr3: Array[int] = [8, 13]
	fish3.set_absolute_arrangement_indexes(arr3)
	var fish_parts3 = fish3.make_fish_parts()
	fish_parts[8] = fish_parts3[0]
	fish_parts[13] = fish_parts3[1]
	
	var fish4 = onebyonefish
	var arr4: Array[int] = [9]
	fish4.set_absolute_arrangement_indexes(arr4)
	var fish_parts4 = fish4.make_fish_parts()
	fish_parts[9] = fish_parts4[0]
	
		
	
func get_fish_part_at_index(i):
	return fish_parts[i]

func get_fish_parts():
	return fish_parts

func set_fish_parts(indexes, new_fish_parts):
	var previous_items: Array[Resource] = []
	var current_ind = 0
	for i in indexes:
		previous_items.append(fish_parts[i])
		fish_parts[i] = new_fish_parts[current_ind]
		current_ind += 1
	emit_signal("fishes_changed", indexes)
	return previous_items
	
func swap_fish_parts(source_indexes, target_indexes):
	var source_fish_parts: Array[Resource] = \
			source_indexes.map(func(i): return fish_parts[i])
	var target_fish_parts: Array[Resource] = \
			target_indexes.map(func(i): return fish_parts[i])
	

	
	

func remove_fish_parts(indexes):
	var previous_items: Array[Resource] = []
	for i in indexes:
		previous_items.append(fish_parts[i])
		fish_parts[i] = null
	emit_signal("fishes_changed", indexes)
	return previous_items
	
