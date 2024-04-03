extends Node2D
class_name Fish

@export var textures: Array[Texture]
@export var arrangement: Array[int]

func _ready():
	var starting_pos = Vector2.ZERO
	for texture in textures:
		var sprite = Sprite2D.new()
		sprite.texture = texture
		sprite.position = starting_pos + Vector2(GS.GRID_SIZE, 0)
		self.add_child(sprite)
