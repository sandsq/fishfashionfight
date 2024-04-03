extends GridContainer

@export var num_slots: int = 9

var inventory = preload("res://inventory/inventory.tres")
var InventorySlotDisplay = preload("res://inventory/inventory_slot_display.tscn")

func _ready():
	for i in range(num_slots):
		add_child(InventorySlotDisplay.instantiate())
	inventory.add_to_inventory()
	inventory.fishes_changed.connect(_on_fishes_changed)
	update_inventory_display()
	

func update_inventory_display():
	for i in range(inventory.get_fish_parts().size()):
		update_inventory_slot_display(i)
		
func update_inventory_slot_display(i):
	var inventory_slot_display = get_child(i)
	var fish_part = inventory.get_fish_parts()[i]
	inventory_slot_display.display_fish_part(fish_part)


func _on_fishes_changed(indexes):
	print("on fishes changed triggered")
	for i in indexes:
		update_inventory_slot_display(i)
