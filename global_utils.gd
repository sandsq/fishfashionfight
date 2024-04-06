extends Node
class_name GS

static var GRID_SIZE = 32
static var INVENTORY_ROWS = 5
static var INVENTORY_COLS = 5
static var INVENTORY_SIZE = INVENTORY_ROWS * INVENTORY_COLS
static var Synergy = preload("res://synergy.tscn")
static var inactive_synergy_color = Plane(0.5, 0.5, 0.5, 0.5)
static var active_synergy_color = Plane(0.2, 0.8, 0.6, 0.5)

static func grid_to_index(grid_pos: Vector2) -> int:
	var i = grid_pos.y * INVENTORY_ROWS + grid_pos.x
	#print("position %s on an %s x %s grid is index %s" % [grid_pos, INVENTORY_ROWS, INVENTORY_COLS, i])
	return i

static func index_to_grid(i: int) -> Vector2:
	@warning_ignore("integer_division")
	var xy = Vector2(floor(i / INVENTORY_COLS), i % INVENTORY_COLS)
	#print("index %s on an %s x %s grid is position %s" % [i, INVENTORY_ROWS, INVENTORY_COLS, xy])
	return xy

static func clone_synergy(s):
	var new_synergy = Synergy.instantiate()
	new_synergy.synergy_data = s.synergy_data.duplicate()
	new_synergy.synergy_condition = s.synergy_condition
	return new_synergy



func _ready():
	if get_tree().current_scene.scene_file_path == "res://battle.tscn" || get_tree().current_scene.scene_file_path == "res://fishing.tscn" || get_tree().current_scene.scene_file_path == "res://inventory/inventory_container.tscn":
		return
	if get_tree().current_scene.scene_file_path != ProjectSettings.get_setting("application/run/main_scene"):
		get_viewport().global_canvas_transform = get_viewport().global_canvas_transform.translated(Vector2(150, 200))
