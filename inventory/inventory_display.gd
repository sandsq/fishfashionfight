extends GridContainer

signal received_hover_signal_from_slot(data)
signal received_fish_part_hover_from_slot(data)

var num_slots: int
var Inventory = preload("res://inventory/inventory.tscn")
var InventorySlotDisplay = preload("res://inventory/inventory_slot_display.tscn")
var battle_scene = preload("res://battle.tscn")
var can_be_dropped = true
var mouse_exited_window = false
var mouse_exited_grid_area = false 

@onready var inventory = Inventory.instantiate()

func _ready():
	self.columns = GS.INVENTORY_COLS
	self.set_size(Vector2(GS.INVENTORY_ROWS * GS.GRID_SIZE, 
			GS.INVENTORY_COLS * GS.GRID_SIZE))
	self.num_slots = GS.INVENTORY_SIZE
	print("num slots %s vs inventory size %s" 
			% [num_slots, inventory.get_fish_parts().size()])
	assert(num_slots == inventory.get_fish_parts().size())

	self.mouse_exited.connect(func(): mouse_exited_grid_area = true)
	self.mouse_entered.connect(func(): mouse_exited_grid_area = false)

	for i in range(num_slots):
		var isd = InventorySlotDisplay.instantiate()
		isd.inventory = inventory
		isd.can_be_dropped_signal.connect(
				func(b): can_be_dropped = b)
		isd.mouse_hovered_over_synergy.connect(
				_on_received_hover_signal_from_slot)
		isd.mouse_hovered_over_fish_part.connect(
				_on_received_fish_part_hovered)
		#isd.set_position(GS.index_to_grid(i) * 1000)
		add_child(isd)
	
	var auto_add = false
	if auto_add:
		inventory.add_to_inventory()
		inventory.fishes_changed.connect(_on_fishes_changed)
	else:
		print("inventory display, not auto adding to inventory")
	
	
	update_inventory_display()
	

func update_inventory_display():
	for i in range(inventory.get_fish_parts().size()):
		update_inventory_slot_display(i)
		
func update_inventory_slot_display(i):
	var inventory_slot_display = get_child(i)
	var fish_part = inventory.get_fish_parts()[i]
	print("visually updating slot %s with fish part %s" % [i, fish_part])
	inventory_slot_display.display_fish_part(fish_part)


func _on_fishes_changed(indexes):
	print("on fishes changed triggered for indexes %s" % [indexes])
	for i in indexes:
		update_inventory_slot_display(i)
	#print("telling inventory display that %s indexes changed, new inventory %s" % [indexes, inventory.get_fish_parts()])
		
func _input(event):
	if event.is_action_released("ui_left_click"):
		if inventory.drag_data != null:
			if not can_be_dropped || mouse_exited_window \
					|| mouse_exited_grid_area:
				#print("@@@@@ in _input, logic for unhandled input, 
						#returning fish parts to %s" % 
						#[inventory.drag_data.fish_absolute_indexes])
				#print("@@@@@ in _input, logic for unhandled input, 
						#can be dropped %s, exited window %s, exited grid %s" % 
						#[can_be_dropped, mouse_exited_window, 
						#mouse_exited_grid_area])
				inventory.set_fish_parts(
						inventory.drag_data.fish_absolute_indexes, 
						inventory.drag_data.fish.make_fish_parts())
			#else:
				#inventory.drag_data = null
						
func _notification(what):
	if what == NOTIFICATION_WM_MOUSE_EXIT:
		#print("inventory display, mouse exited window")
		mouse_exited_window = true
	elif what == NOTIFICATION_WM_MOUSE_ENTER:
		#print("inventory display, mouse entered window")
		mouse_exited_window = false
		
func _on_received_hover_signal_from_slot(data):
	emit_signal("received_hover_signal_from_slot", data)

func _on_received_fish_part_hovered(data):
	#print("fish part hovered, in invent display, data %s" % [data])
	emit_signal("received_fish_part_hover_from_slot", data)


