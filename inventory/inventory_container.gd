extends ColorRect

var battle_scene = preload("res://battle.tscn")
var InventoryDisplay = preload("res://inventory/inventory_display.tscn")
var Inventory = preload("res://inventory/inventory.tscn")

@onready var player_display = $CenterContainer/ActiveInventoryDisplay
@onready var info_label = %InfoLabel
@onready var fish_part_info = %FishPartInfo

func _ready():
	pass
	#player_display.received_hover_signal_from_slot.connect(_change_info)
	#player_display.received_hover_fish_part.connect(func(): print("???"))

func _on_change_scene_button_pressed():
	
	var old_scene = player_display
	var new_scene = battle_scene.instantiate()
	new_scene.previous_scene = old_scene
	var current_inventory = player_display.inventory.get_fish_parts().slice(0, 25)
	print("inventory right before switching to battle scene %s" 
			% [current_inventory])
	new_scene.player_fish_parts = current_inventory
	
	var enemy_display = InventoryDisplay.instantiate()
	enemy_display.global_position = Vector2(-4000, -4000)
	add_child(enemy_display)
	enemy_display.inventory.add_to_inventory()
	enemy_display.update_inventory_display()
	
	new_scene.enemy_fish_parts = enemy_display.inventory.get_fish_parts().slice(0, 25)
	
	get_tree().root.add_child(new_scene)
	
	old_scene.visible = false

func _change_info(data):
	info_label.text = str(data)





func _on_active_inventory_display_received_fish_part_hover_from_slot(data):
	print("invent container, data %s" % data)
	fish_part_info.text = "Damage: %s" % data.damage
