extends Node2D

signal fishes_changed(indexes) ## array of positions that changed
signal adding_failed

@export var inventory_fish_parts: Array = [
	null, null, null, null, null, 
	null, null, null, null, null, 
	null, null, null, null, null, 
	null, null, null, null, null, 
	null, null, null, null, null,
	null, null, null, null, null,
]

var UFish = preload("res://fish/u_fish.tscn")
var OneByTwo = preload("res://fish/one_by_two.tscn")
var TwoByOne = preload("res://fish/two_by_one.tscn")
var OneByOne = preload("res://fish/one_by_one.tscn")
var Synergy = preload("res://synergy.tscn")
var drag_data = null
var first_empty_index = 0 ## for more efficiency, could only check starting from empty slots. But a bit harder to track so not doing this for now
var rng = RandomNumberGenerator.new()

func _ready():
	rng.seed = hash("fish")

## finds the first available slot that can fit the fish
func add_fish_to_inventory(fish_to_add, synergy):
	print("adding fish %s, it should already be instantiated" % fish_to_add)
	var fish_parts = fish_to_add.make_fish_parts()
	var relative_indexes = fish_to_add.get_arrangement_indexes()
	var can_place = true
	var fish_placed = false
	for starting_index_to_try \
			in range(first_empty_index, inventory_fish_parts.size()):
		var new_abs_inds: Array[int] = []
		for rel_ind in relative_indexes:
			var index_to_try = starting_index_to_try + rel_ind
			if index_to_try >= inventory_fish_parts.size():
				can_place = false
				break
			new_abs_inds.append(index_to_try)
			#print("starting at index %s, trying that + %s, ie %s, inventory contains %s there" 
					#% [starting_index_to_try, rel_ind, index_to_try, inventory_fish_parts[index_to_try]])
			if inventory_fish_parts[index_to_try] != null:
				can_place = false
				break
		if can_place == true:
			#print("\tcan place that fish")
			# if we make it here, then all positions are valid, 
			# so we don't need to look anymore
			fish_to_add.set_absolute_arrangement_indexes(new_abs_inds)
			assert(new_abs_inds.size() == fish_parts.size())
			for fish_part_index in fish_parts.size():
				#print("\tadding fish part %s" % fish_parts[fish_part_index])
				inventory_fish_parts[new_abs_inds[fish_part_index]] \
						= fish_parts[fish_part_index]
			
			var rand_ind = rng.randi_range(0, fish_parts.size() - 1)
			var rand_fish_part = fish_parts[rand_ind]
			var rand_fish_part_abs_ind = new_abs_inds[rand_ind]
			var is_valid_synergy_placement = false
			var fallback_counter = 0
			var rand_side = 0
			var previous_side = -1
			# synergy won't change at this point, 
			# but this can check if we should even do these next steps
			while synergy != null and not is_valid_synergy_placement:
				rand_side = rng.randi_range(0, 4)
				if rand_side == previous_side:
					continue
				if rand_side == 0: 
					# slot above this fish part will be # rows back
					var potential_spot = \
							rand_fish_part_abs_ind - GS.INVENTORY_ROWS
					if not new_abs_inds.has(potential_spot):
						is_valid_synergy_placement = true
				elif rand_side == 1:
					var potential_spot = rand_fish_part_abs_ind + 1
					if not new_abs_inds.has(potential_spot):
						is_valid_synergy_placement = true
				elif rand_side == 2:
					var potential_spot = \
							rand_fish_part_abs_ind + GS.INVENTORY_ROWS
					if not new_abs_inds.has(potential_spot):
						is_valid_synergy_placement = true
				elif rand_side == 3:
					var potential_spot = rand_fish_part_abs_ind - 1
					if not new_abs_inds.has(potential_spot):
						is_valid_synergy_placement = true
				
				if is_valid_synergy_placement and previous_side == -1:
					# 50% change to add another synergy
					var roll = rng.randf()
					print("roll %s, double the synergy?" 
								% roll)
					if roll <= 0.25:
						previous_side = rand_side
						is_valid_synergy_placement = false
				fallback_counter += 1
				if fallback_counter >= 10:
					print("hitting fallback")
					break
					
			if is_valid_synergy_placement:
				if previous_side != -1:
					rand_fish_part.set_adjacent_synergy_to_provide(
							synergy, previous_side)
				rand_fish_part.set_adjacent_synergy_to_provide(
						synergy, rand_side)
				
			
			fish_placed = true
			emit_signal("fishes_changed", new_abs_inds)
			break
		else:
			# if we make it here, then there was an invalid place, so we need to try the next starting location
			can_place = true
			
	if not fish_placed:
		print("couldn't find place for fish")
		emit_signal("adding_failed")
	
	return fish_placed
	

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
		inventory_fish_parts[part_ind] = ufish_part
		current_ind += 1
	
	var fish1 = OneByTwo.instantiate()
	var fish2 = OneByTwo.instantiate()
	var arr: Array[int] = [3, 4]
	var arr2: Array[int] = [15, 16]
	fish1.set_absolute_arrangement_indexes(arr)
	fish2.set_absolute_arrangement_indexes(arr2)
	var fish_parts1x2 = fish1.make_fish_parts()
	var fish_parts1x2_2 = fish2.make_fish_parts()
	inventory_fish_parts[3] = fish_parts1x2[0]
	inventory_fish_parts[4] = fish_parts1x2[1]
	inventory_fish_parts[15] = fish_parts1x2_2[0]
	inventory_fish_parts[16] = fish_parts1x2_2[1]
	
	var fish3 = TwoByOne.instantiate()
	var arr3: Array[int] = [8, 13]
	fish3.set_absolute_arrangement_indexes(arr3)
	var fish_parts3 = fish3.make_fish_parts()
	inventory_fish_parts[8] = fish_parts3[0]
	inventory_fish_parts[13] = fish_parts3[1]
	
	var fish4 = OneByOne.instantiate()
	var arr4: Array[int] = [9]
	fish4.set_absolute_arrangement_indexes(arr4)
	var fish_parts4 = fish4.make_fish_parts()
	var testpart = fish_parts4[0]
	var testsynergy4 = Synergy.instantiate()
	testsynergy4.synergy_data = {"damage_boost": 2.0}
	testpart.set_adjacent_synergy_to_provide(testsynergy4, 2)
	print("add_to_inventory adding some synergies")
	var testsynergy42 = Synergy.instantiate()
	testsynergy42.synergy_data = {"damage_boost": 3.0}
	testpart.set_adjacent_synergy_to_provide(testsynergy42, 0)
	inventory_fish_parts[9] = testpart
	
	var fish5 = OneByOne.instantiate()
	var arr5: Array[int] = [6]
	fish5.set_absolute_arrangement_indexes(arr5)
	var fish_parts5 = fish5.make_fish_parts()
	inventory_fish_parts[6] = fish_parts5[0]
	
	var fish6 = OneByOne.instantiate()
	var arr6: Array[int] = [14]
	fish6.set_absolute_arrangement_indexes(arr6)
	var fish_parts6 = fish6.make_fish_parts()
	inventory_fish_parts[14] = fish_parts6[0]
	
func get_fish_part_at_index(i):
	return inventory_fish_parts[i]

func get_fish_parts():
	return inventory_fish_parts

func set_fish_parts(indexes, new_fish_parts):
	var previous_items: Array = []
	var current_ind = 0
	for i in indexes:
		previous_items.append(inventory_fish_parts[i])
		inventory_fish_parts[i] = new_fish_parts[current_ind]
		current_ind += 1	
	print("setting %s to new fish parts %s" % [indexes, new_fish_parts])
	emit_signal("fishes_changed", indexes)
	return previous_items
	

func remove_fish_parts(indexes):
	var previous_items: Array = []
	for i in indexes:
		previous_items.append(inventory_fish_parts[i])
		inventory_fish_parts[i] = null
	print("removing fish parts at %s, inventory should by %s" % [indexes, inventory_fish_parts])
	emit_signal("fishes_changed", indexes)
	return previous_items
	

func _on_synergy_entered(_area):
	print("something entered synergy area")
