extends CharacterBody2D
class_name Character

@export var flipped: bool = false

var fish_part_weapons = null
var poison_turns = 0:
	set(value):
		poison_turns = value
		if poison_turns > 0:
			status_label.text = str(poison_turns)
		else:
			status_label.text = ""

@onready var character_sprite = $Sprite2D
@onready var character_stats = $CharacterStats
@onready var weapon = $Weapon
@onready var hp_label = $HPLabel
@onready var damage_label = $DamageLabel
@onready var animation_player = $AnimationPlayer
@onready var hurtbox_collision = $Hurtbox/CollisionShape2D
@onready var status_label = $StatusLabel

func _ready():
	if flipped:
		character_sprite.flip_h = true
		weapon.set_position(Vector2(8, 0))
		damage_label.set_position(Vector2(32 + 8, 24))
		status_label.set_position(Vector2(32 + 16, 40))
	else:
		weapon.set_position(Vector2(56, 0))
	character_stats.current_health = character_stats.current_health
	character_stats.max_health = character_stats.max_health


func draw_weapon(fish_part, damage_mult = 1.0, duration=0.25):
	weapon.set_weapon_damage(fish_part.damage * damage_mult)
	weapon.set_poison_turns(fish_part.poison)
	weapon.set_position(Vector2(16, 32))
	await get_tree().create_timer(duration).timeout
	weapon.texture = fish_part.get_parent_fish().texture
	var tween = create_tween()
	var tween_pos = Vector2(56, 0)
	if flipped:
		tween_pos = Vector2(8, 0)
	tween.tween_property(weapon, "position", tween_pos, duration)
	tween.play()
	await tween.finished

func attack(fish_part, target_position, duration=0.4, rotation_amount=720.0):
	if poison_turns > 0:
		poison_turns -= 1
		character_stats.current_health -= pow(1.1, poison_turns)
		draw_damage_label(-pow(1.1, poison_turns), Color(0.42, 0.0, 0.44))
		print("%s took poison damage %s" % [self.name, pow(1.1, poison_turns)])
		animation_player.play("poison")
	var weapon_start_position = weapon.global_position
	var tween = create_tween()
	tween.tween_property(weapon, "global_position", target_position, duration)
	tween.parallel().tween_property(weapon, "global_rotation_degrees", rotation_amount, duration)
	await tween.finished
	if fish_part.lifesteal > 0:
		self.heal(weapon.get_weapon_damage() * fish_part.lifesteal)
	var tween_back = create_tween()
	tween_back.tween_property(weapon, "global_position", weapon_start_position, duration / 2)
	tween_back.play()
	await tween_back.finished

func heal(heal_amount):
	if poison_turns > 0:
		poison_turns = 0
		heal_amount = 0
		print("nullifying healing, removing poison stacks")
	self.character_stats.current_health += heal_amount
	draw_damage_label(heal_amount, Color(0.2, 0.8, 0.1))
	print("%s healed %s damage" % [self.name, snapped(heal_amount, 0.1)])
	#damage_label.text = "+%.1f" % heal_amount
	animation_player.play("heal")

func draw_damage_label(value, d_color):
	var d_lab = Label.new()
	add_child(d_lab)
	d_lab.add_theme_color_override("font_color", d_color)
	d_lab.add_theme_font_size_override("font_size", 8)
	d_lab.text = "%.1f" % value
	d_lab.global_position = damage_label.global_position
	
	var offset1 = Vector2(16, 16)
	var offset2 = Vector2(32, 16)
	if flipped:
		offset1 = Vector2(-16, 16)
		offset2 = Vector2(-32, 16)
	
	var d_tween = create_tween()
	d_tween.tween_property(d_lab, "global_position", d_lab.global_position - offset1, 0.3)
	d_tween.tween_property(d_lab, "global_position", d_lab.global_position - offset2, 0.3)
	d_tween.parallel().tween_property(d_lab, "modulate:a", 0.0, 0.4)
	d_tween.play()
	await d_tween.finished
	d_lab.queue_free()

func _on_hurtbox_area_entered(area):
	var damage_taken = area.damage
	if area.poison > 0:
		poison_turns = area.poison
		print("%s poisoned for %s turns" % [self.name, area.poison])
	character_stats.current_health -= damage_taken
	print("%s took %s damage" % [self.name, snapped(damage_taken, 0.1)])
	
	draw_damage_label(-damage_taken, Color(0.7, 0.2, 0.1))
	
	


func _on_character_stats_health_changed(_new_health):
	hp_label.text = "%.1f / %s" % [character_stats.current_health, character_stats.max_health]


func _on_character_stats_max_health_changed(_new_max_health):
	pass # Replace with function body.


func _on_character_stats_no_health():
	pass # Replace with function body.
