extends CenterContainer

@onready var fish_texture_rect = $FishTextureRect

func display_fish(fish):
	if fish is Fish:
		fish_texture_rect.texture = fish.texture
	else:
		fish_texture_rect.texture = load("res://assets/inventory_placeholder.png")
