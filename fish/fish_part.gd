extends Resource
class_name FishPart

var parent_fish: Entity
var texture: Texture
var position: Vector2

func get_parent_fish() -> Entity:
	return parent_fish
	
	
func set_parent_fish(new_fish: Entity):
	parent_fish = new_fish

func get_texture():
	return texture
	
func set_texture(new_texture):
	texture = new_texture

func get_position():
	return position
	
func set_position(new_position):
	position = new_position
