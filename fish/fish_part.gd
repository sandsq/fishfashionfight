extends Node2D
class_name FishPart

@export var damage: int = 1

var parent_fish: Entity
var texture: Texture


func get_parent_fish() -> Entity:
	return parent_fish
	
	
func set_parent_fish(new_fish: Entity):
	parent_fish = new_fish

func get_texture():
	return texture
	
func set_texture(new_texture):
	texture = new_texture
