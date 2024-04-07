extends Node2D
class_name FishPart

@export var damage: float = 1
@export var lifesteal: float = 0.0
@export var poison: int = 0

var parent_fish: Entity
var texture: Texture
var adjacent_parts: Array = [null, null, null, null] ## north east south west
var adjacent_synergies_to_provide: Array = [null, null, null, null]
## if something is in index 0, the fish giving it that synergy gave it from the north
var received_synergy_data = [{}, {}, {}, {}] 


func perform_fish_part_action():
	pass

func get_parent_fish() -> Entity:
	return parent_fish
	
func set_parent_fish(new_fish: Entity):
	parent_fish = new_fish

func get_texture():
	return texture
	
func set_texture(new_texture):
	texture = new_texture

func clear_received_synergy_data():
	received_synergy_data = {}

func set_received_synergy_data(new_received_synergy_data, i):
	print("updated synergy data with %s at %s" % [new_received_synergy_data, i])
	received_synergy_data[i] = new_received_synergy_data
	
func process_received_synergy_data():
	#print("synergy data is %s" % received_synergy_data)
	for single_synergy_data in received_synergy_data:
		if single_synergy_data.has("damage_boost"):
			damage = damage * single_synergy_data.damage_boost
		if single_synergy_data.has("lifesteal_amount"):
			lifesteal += single_synergy_data.lifesteal_amount
	return received_synergy_data

func set_adjacent_synergy_to_provide(data, ind):
	if adjacent_parts[ind] != null:
		print("@@@@ something broke, trying to provide a synergy to a slot that is taken up by another part of the same fish")
		return
	adjacent_synergies_to_provide[ind] = data
