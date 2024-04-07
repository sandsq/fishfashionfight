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
var player_damage_mult = 1.0
var enemy_damage_mult = 1.0
var did_player_win = false
var battle_ended = false


@onready var inventory_display = $InventoryDisplay
@onready var enemy_inventory_display = $EnemyInventoryDisplay
@onready var player = $Player
@onready var enemy = $Enemy
@onready var info_label = $InfoLabel
@onready var enemy_info_label = $EnemyInfoLabel
@onready var victory_label = $VictoryLabel

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
	
	player.character_stats.no_health.connect(_on_player_no_health)
	enemy.character_stats.no_health.connect(_on_enemy_no_health)


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
	var info_label_to_use = info_label if character.name == "Player" else enemy_info_label
	var current_fish_ind = 0
	for fish_part in character.fish_part_weapons:
		if battle_ended:
			break
		indicator.global_position = \
				display.get_child(current_fish_ind).global_position
		if fish_part != null:
			var synergies_activated = fish_part.process_received_synergy_data()
			for s in synergies_activated:
				if s != {}:
					info_label_to_use.text += str(s)
			var damage_mult = 1.0
			var rotation_amount = 720.0
			if character.name == "Player":
				damage_mult = player_damage_mult
			if character.name == "Enemy":
				damage_mult = enemy_damage_mult
				rotation_amount = -720.0
			await character.draw_weapon(fish_part, damage_mult)
			await character.attack(fish_part, opponent.global_position + Vector2(50, 50), 0.4, rotation_amount)
			character.weapon.texture = null
			info_label_to_use.text = ""
		else:
			character.weapon.texture = null
		await get_tree().create_timer(
				character.character_stats.attack_speed).timeout
		current_fish_ind += 1
	if character.name == "Player":
		player_damage_mult += 0.1
		executing_player_attacks = false
	if character.name == "Enemy":
		enemy_damage_mult += 0.1
		executing_enemy_attacks = false
	

func return_to_fishing():
	
	var Fishing = load("res://fishing.tscn")
	var fishing = Fishing.instantiate()
	get_tree().root.add_child(fishing)
	for child in get_tree().root.get_children():
		if child != fishing:
			get_tree().root.remove_child(child)
		


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
	indicator.color = Color(0.9, 0.9, 0.9, 0.8)
	indicator.z_index = 1
	#inventory_display_highlighter.set_position(
			#inventory_display.get_child(0).global_position)
	return indicator

func _on_button_pressed():
	return_to_fishing()

func _on_player_no_health():
	print("player ran out of health")
	did_player_win = false
	battle_ended = true
	victory_label.text = "You lost :( Try again!"

func _on_enemy_no_health():
	print("enemy ran out of health")
	did_player_win = true
	battle_ended = true
	victory_label.text = "You won! Level %s -> %s. Keep going!" % [GS.level, GS.level + 1]
	GS.level += 1
	


func _on_button_2_pressed():
	previous_scene.set_process(false)
	previous_scene.scale = Vector2(0.75, 0.75)
	previous_scene.position = Vector2(200, 100)
	previous_scene.z_index = 5
	previous_scene.visible = not previous_scene.visible
