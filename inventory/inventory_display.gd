extends GridContainer

var num_slots: int
var inventory = preload("res://inventory/inventory.tres")
var InventorySlotDisplay = preload("res://inventory/inventory_slot_display.tscn")


func _ready():
	self.columns = GS.INVENTORY_COLS
	self.set_size(Vector2(GS.INVENTORY_ROWS * GS.GRID_SIZE, GS.INVENTORY_COLS * GS.GRID_SIZE))
	self.num_slots = GS.INVENTORY_SIZE
	print("num slots %s vs inventory size %s" % [num_slots, inventory.get_fish_parts().size()])
	assert(num_slots == inventory.get_fish_parts().size())

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
	print("updating slot %s with fish part %s" % [i, fish_part])
	inventory_slot_display.display_fish_part(fish_part)


func _on_fishes_changed(indexes):
	print("on fishes changed triggered for indexes %s" % [indexes])
	for i in indexes:
		update_inventory_slot_display(i)
