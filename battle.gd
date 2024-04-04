extends Node2D

var inventory = null
var previous_scene = null

@onready var inventory_display = $InventoryDisplay

# Called when the node enters the scene tree for the first time.
func _ready():
	if inventory == null:
		print("inventory null, something is wrong")
		return
	if previous_scene == null:
		print("previous scene null, something is wrong")
		return
	print("inventory in battle scene _ready %s" % [inventory])
	for fish_part in inventory:
		var fish_to_display = TextureRect.new()
		if fish_part is FishPart:
			var fish = fish_part.get_parent_fish()
			fish_to_display.texture = fish.texture
		else:
			fish_to_display.texture = load("res://assets/inventory_placeholder.png")
		fish_to_display.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		fish_to_display.custom_minimum_size = Vector2(96, 96)
		inventory_display.add_child(fish_to_display)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	self.visible = false
	previous_scene.visible = true
