extends Node2D

signal fishes_changed(indexes) ## array of positions that changed

@export var fish_parts: Array = [
	null, null, null, null, null, 
	null, null, null, null, null, 
	null, null, null, null, null, 
	null, null, null, null, null, 
	null, null, null, null, null
]

var UFish = preload("res://fish/u_fish.tscn")
var OneByTwo = preload("res://fish/one_by_two.tscn")
var TwoByOne = preload("res://fish/two_by_one.tscn")
var OneByOne = preload("res://fish/one_by_one.tscn")
var Synergy = preload("res://synergy.tscn")
var drag_data = null
	
func add_to_inventory():
	var ufishtest = UFish.instantiate()
	var ufish_parts = ufishtest.make_fish_parts()
	var ufish_parts_abs_inds = ufishtest.get_absolute_arrangement_indexes()
	print("adding ufish parts %s at abs inds %s" % [ufish_parts, ufish_parts_abs_inds])
	var current_ind = 0
	for part_ind in ufish_parts_abs_inds:
		print("adding the %s th ufish part to inventory slot %s" 
				% [current_ind, part_ind])
		var ufish_part = ufish_parts[current_ind]
		if current_ind == 5:
			var testsynergy = Synergy.instantiate()
			testsynergy.synergy_data = {"damage_boost": 8.0, "notes": "Only grants bonus to 2x1 fish."}
			testsynergy.synergy_condition = func(test_val): 
					if not test_val.has("species"):
						return false
					else:
						return test_val.species == "two_by_one" 
			ufish_part.set_adjacent_synergy_to_provide(testsynergy, 0)
		fish_parts[part_ind] = ufish_part
		current_ind += 1
	
	var fish1 = OneByTwo.instantiate()
	var fish2 = OneByTwo.instantiate()
	var arr: Array[int] = [3, 4]
	var arr2: Array[int] = [15, 16]
	fish1.set_absolute_arrangement_indexes(arr)
	fish2.set_absolute_arrangement_indexes(arr2)
	var fish_parts1x2 = fish1.make_fish_parts()
	var fish_parts1x2_2 = fish2.make_fish_parts()
	fish_parts[3] = fish_parts1x2[0]
	fish_parts[4] = fish_parts1x2[1]
	fish_parts[15] = fish_parts1x2_2[0]
	fish_parts[16] = fish_parts1x2_2[1]
	
	var fish3 = TwoByOne.instantiate()
	var arr3: Array[int] = [8, 13]
	fish3.set_absolute_arrangement_indexes(arr3)
	var fish_parts3 = fish3.make_fish_parts()
	fish_parts[8] = fish_parts3[0]
	fish_parts[13] = fish_parts3[1]
	
	var fish4 = OneByOne.instantiate()
	var arr4: Array[int] = [9]
	fish4.set_absolute_arrangement_indexes(arr4)
	var fish_parts4 = fish4.make_fish_parts()
	var testpart = fish_parts4[0]
	var testsynergy4 = Synergy.instantiate()
	testsynergy4.synergy_data = {"damage_boost": 2.0}
	testpart.set_adjacent_synergy_to_provide(testsynergy4, 2)
	var testsynergy42 = Synergy.instantiate()
	testsynergy42.synergy_data = {"damage_boost": 3.0}
	testpart.set_adjacent_synergy_to_provide(testsynergy42, 0)
	fish_parts[9] = testpart
	
	var fish5 = OneByOne.instantiate()
	var arr5: Array[int] = [6]
	fish5.set_absolute_arrangement_indexes(arr5)
	var fish_parts5 = fish5.make_fish_parts()
	fish_parts[6] = fish_parts5[0]
	
	var fish6 = OneByOne.instantiate()
	var arr6: Array[int] = [14]
	fish6.set_absolute_arrangement_indexes(arr6)
	var fish_parts6 = fish6.make_fish_parts()
	fish_parts[14] = fish_parts6[0]
	
func get_fish_part_at_index(i):
	return fish_parts[i]

func get_fish_parts():
	return fish_parts

func set_fish_parts(indexes, new_fish_parts):
	var previous_items: Array = []
	var current_ind = 0
	for i in indexes:
		previous_items.append(fish_parts[i])
		fish_parts[i] = new_fish_parts[current_ind]
		current_ind += 1	
	print("setting %s to new fish parts %s" % [indexes, new_fish_parts])
	emit_signal("fishes_changed", indexes)
	return previous_items
	

func remove_fish_parts(indexes):
	var previous_items: Array = []
	for i in indexes:
		previous_items.append(fish_parts[i])
		fish_parts[i] = null
	print("removing fish parts at %s, inventory should by %s" % [indexes, fish_parts])
	emit_signal("fishes_changed", indexes)
	return previous_items
	

func _on_synergy_entered(_area):
	print("something entered synergy area")
