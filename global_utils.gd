extends Node
class_name GS

static var GRID_SIZE = 32
static var INVENTORY_ROWS = 3
static var INVENTORY_COLS = 3
static var INVENTORY_SIZE = INVENTORY_ROWS * INVENTORY_COLS

static func grid_to_index(grid_pos: Vector2) -> int:
	return grid_pos.y * INVENTORY_ROWS + grid_pos.x
