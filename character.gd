extends CharacterBody2D
class_name Character

@export var flipped: bool = false

var fish_part_weapons = null

@onready var character_sprite = $Sprite2D
@onready var character_stats = $CharacterStats
@onready var weapon = $Weapon
@onready var hp_label = $HPLabel

func _ready():
	if flipped:
		character_sprite.flip_h = true
		weapon.set_position(Vector2(8, 0))
	else:
		weapon.set_position(Vector2(56, 0))

func _process(_delta):
	if Input.is_action_just_pressed("attack"):
		if self.name == "Player":
			print("dummy attack for testing purposes")
			attack(Vector2(290, 150))

func draw_weapon(fish_part, duration=0.25):
	weapon.set_weapon_damage(fish_part.damage)
	weapon.set_position(Vector2(16, 32))
	await get_tree().create_timer(duration).timeout
	weapon.texture = fish_part.get_parent_fish().texture
	var tween = create_tween()
	tween.tween_property(weapon, "position", Vector2(56, 0), duration)
	tween.play()
	await tween.finished

func attack(target_position, duration=0.4):
	var weapon_start_position = weapon.global_position
	var tween = create_tween()
	tween.tween_property(weapon, "global_position", target_position, duration)
	await tween.finished
	var tween_back = create_tween()
	tween_back.tween_property(weapon, "global_position", weapon_start_position, duration / 2)
	tween_back.play()
	await tween_back.finished
	

func _on_hurtbox_area_entered(area):
	var damage_taken = area.damage
	character_stats.current_health -= damage_taken
	#print("character %s got hurt by something entering its hurtbox" % self.name)
	var damage_label = Label.new()
	damage_label.text = "-%s" % damage_taken
	damage_label.set_position(Vector2(32, 16))
	add_child(damage_label)
	


func _on_character_stats_health_changed(_new_health):
	hp_label.text = "%s / %s" % [character_stats.current_health, character_stats.max_health]


func _on_character_stats_max_health_changed(_new_max_health):
	pass # Replace with function body.


func _on_character_stats_no_health():
	pass # Replace with function body.
