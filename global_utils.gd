extends Node
class_name GS

static var GRID_SIZE = 32
static var INVENTORY_ROWS = 3
static var INVENTORY_COLS = 3
static var INVENTORY_SIZE = INVENTORY_ROWS * INVENTORY_COLS

static func grid_to_index(grid_pos: Vector2) -> int:
	var i = grid_pos.y * INVENTORY_ROWS + grid_pos.x
	print("position %s on an %s x %s grid is index %s" % [grid_pos, INVENTORY_ROWS, INVENTORY_COLS, i])
	return i

static func index_to_grid(i: int) -> Vector2:
	var xy = Vector2(floor(i / INVENTORY_COLS), i % INVENTORY_COLS)
	print("index %s on an %s x %s grid is position %s" % [i, INVENTORY_ROWS, INVENTORY_COLS, xy])
	return xy
