extends Node2D

#var inventory = null
var player_fish_parts = null
var enemy_fish_parts = null
var previous_scene = null
var executing_player_attacks = false
var executing_enemy_attacks = false
var placeholder_texture = preload("res://assets/inventory_placeholder.png")
var inventory_display_highlighter = null
var enemy_inventory_display_highlighter = null

@onready var inventory_display = $InventoryDisplay
@onready var enemy_inventory_display = $EnemyInventoryDisplay
@onready var player = $Player
@onready var enemy = $Enemy
@onready var info_label = $InfoLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	player.fish_part_weapons = player_fish_parts
	enemy.fish_part_weapons = enemy_fish_parts
	if player.fish_part_weapons == null:
		print("inventory null, something is wrong")
		return
	if previous_scene == null:
		print("previous scene null, something is wrong")
		return
	print("inventory in battle scene _ready %s" % [player.fish_part_weapons])
	
	_populate_inventory_display(player, inventory_display)
	inventory_display_highlighter = _create_inventory_indicator()
	_populate_inventory_display(enemy, enemy_inventory_display)
	enemy_inventory_display_highlighter = _create_inventory_indicator()
	add_child(inventory_display_highlighter)
	add_child(enemy_inventory_display_highlighter)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if player.fish_part_weapons == null || previous_scene == null:
		return

	if not executing_player_attacks:
		executing_player_attacks = true
		execute_actions(player, enemy, inventory_display, inventory_display_highlighter)
	if not executing_enemy_attacks:
		executing_enemy_attacks = true
		execute_actions(enemy, player, enemy_inventory_display, enemy_inventory_display_highlighter)


func execute_actions(character, opponent, display, indicator):
	var current_fish_ind = 0
	for fish_part in character.fish_part_weapons:
		indicator.global_position = \
				display.get_child(current_fish_ind).global_position
		if fish_part != null:
			var synergies_activated = fish_part.process_received_synergy_data()
			for s in synergies_activated:
				if s != {}:
					info_label.text += str(s)
					
			await character.draw_weapon(fish_part)
			await character.attack(opponent.global_position + Vector2(50, 50))
			character.weapon.texture = null
		else:
			character.weapon.texture = null
			info_label.text = ""
		await get_tree().create_timer(
				character.character_stats.attack_speed).timeout
		current_fish_ind += 1
	
		


func _populate_inventory_display(character, display):
	for fish_part in character.fish_part_weapons:
		var fish_to_display = TextureRect.new()
		if fish_part is FishPart:
			var fish = fish_part.get_parent_fish()
			fish_to_display.texture = fish.texture
		else:
			fish_to_display.texture = placeholder_texture
		fish_to_display.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		fish_to_display.custom_minimum_size = Vector2(96, 96)
		display.add_child(fish_to_display)


func _create_inventory_indicator():
	var indicator = ColorRect.new()
	indicator.set_size(Vector2(48, 48))
	indicator.color = "#ffffff"
	indicator.z_index = 1
	#inventory_display_highlighter.set_position(
			#inventory_display.get_child(0).global_position)
	return indicator

func _on_button_pressed():
	self.visible = false
	previous_scene.visible = true

