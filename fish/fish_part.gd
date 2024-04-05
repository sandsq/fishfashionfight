extends Node2D
class_name FishPart

@export var damage: int = 1

var parent_fish: Entity
var texture: Texture
var adjacent_parts: Array = [null, null, null, null] ## north east south west
var adjacent_synergies_to_provide: Array = [null, null, null, null]
var received_synergy_data = {}


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

func set_received_synergy_data(new_received_synergy_data):
	received_synergy_data = new_received_synergy_data
	
func process_received_synergy_data():
	if received_synergy_data.has("damage_boost"):
		damage = damage * received_synergy_data.damage_boost

func set_adjacent_synergy_to_provide(data, ind):
	if adjacent_parts[ind] != null:
		print("@@@@ something broke, trying to provide a synergy to a slot that is taken up by another part of the same fish")
		return
	adjacent_synergies_to_provide[ind] = data
