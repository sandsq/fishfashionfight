extends Sprite2D

@onready var weapon_hitbox = $WeaponHitbox



func set_weapon_damage(new_damage):
	weapon_hitbox.damage = new_damage
