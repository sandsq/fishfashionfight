extends Node2D

var inventory = null
var previous_scene = null
var executing_player_attacks = false
var executing_enemy_attacks = false
var placeholder_texture = preload("res://assets/inventory_placeholder.png")
var inventory_display_highlighter = null

@onready var inventory_display = $InventoryDisplay
@onready var player = $Player
@onready var enemy = $Enemy

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
			fish_to_display.texture = placeholder_texture
		fish_to_display.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		fish_to_display.custom_minimum_size = Vector2(96, 96)
		inventory_display.add_child(fish_to_display)
	inventory_display_highlighter = ColorRect.new()
	inventory_display_highlighter.set_size(Vector2(48, 48))
	inventory_display_highlighter.color = "#ffffff"
	inventory_display_highlighter.z_index = 1
	#inventory_display_highlighter.set_position(
			#inventory_display.get_child(0).global_position)
	add_child(inventory_display_highlighter)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if inventory == null || previous_scene == null:
		return

	if not executing_player_attacks:
		executing_player_attacks = true
		execute_player_attacks()


func execute_player_attacks():
	var current_fish_ind = 0
	for fish in inventory:
		inventory_display_highlighter.global_position = inventory_display.get_child(current_fish_ind).global_position
		if fish != null:
			await player.draw_weapon(fish.get_parent_fish().texture)
			await player.attack(enemy.global_position + Vector2(50, 50))
			player.weapon.texture = null
		else:
			player.weapon.texture = null
		await get_tree().create_timer(
				player.character_stats.attack_speed).timeout
		current_fish_ind += 1
		
	
	
func execute_enemy_attacks():
	pass


func _on_button_pressed():
	self.visible = false
	previous_scene.visible = true

