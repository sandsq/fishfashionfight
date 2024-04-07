extends CharacterBody2D
class_name Character

@export var flipped: bool = false

var fish_part_weapons = null

@onready var character_sprite = $Sprite2D
@onready var character_stats = $CharacterStats
@onready var weapon = $Weapon
@onready var hp_label = $HPLabel
@onready var damage_label = $DamageLabel
@onready var animation_player = $AnimationPlayer

func _ready():
	if flipped:
		character_sprite.flip_h = true
		weapon.set_position(Vector2(8, 0))
	else:
		weapon.set_position(Vector2(56, 0))
	character_stats.current_health = character_stats.current_health
	character_stats.max_health = character_stats.max_health


func draw_weapon(fish_part, damage_mult = 1.0, duration=0.25):
	weapon.set_weapon_damage(fish_part.damage * damage_mult)
	weapon.set_position(Vector2(16, 32))
	await get_tree().create_timer(duration).timeout
	weapon.texture = fish_part.get_parent_fish().texture
	var tween = create_tween()
	tween.tween_property(weapon, "position", Vector2(56, 0), duration)
	tween.play()
	await tween.finished

func attack(fish_part, target_position, duration=0.4, rotation=720.0):
	var weapon_start_position = weapon.global_position
	var tween = create_tween()
	tween.tween_property(weapon, "global_position", target_position, duration)
	tween.parallel().tween_property(weapon, "global_rotation_degrees", rotation, duration)
	await tween.finished
	if fish_part.lifesteal > 0:
		self.heal(weapon.get_weapon_damage() * fish_part.lifesteal)
	var tween_back = create_tween()
	tween_back.tween_property(weapon, "global_position", weapon_start_position, duration / 2)
	tween_back.play()
	await tween_back.finished

func heal(heal_amount):
	self.character_stats.current_health += heal_amount
	print("%s healed %s damage" % [self.name, snapped(heal_amount, 0.1)])
	damage_label.text = "+%.1f" % heal_amount
	animation_player.play("heal")

func _on_hurtbox_area_entered(area):
	var damage_taken = area.damage
	character_stats.current_health -= damage_taken
	print("%s took %s damage" % [self.name, snapped(damage_taken, 0.1)])
	#print("character %s got hurt by something entering its hurtbox" % self.name)
	damage_label.text = "-%.1f" % damage_taken
	


func _on_character_stats_health_changed(_new_health):
	hp_label.text = "%.1f / %s" % [character_stats.current_health, character_stats.max_health]


func _on_character_stats_max_health_changed(_new_max_health):
	pass # Replace with function body.


func _on_character_stats_no_health():
	pass # Replace with function body.
