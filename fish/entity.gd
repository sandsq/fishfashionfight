extends Node2D
class_name Entity

@export var texture: Texture
@export var arrangement: Array[Vector2] ## specifies fish shape with 2d indexes

var absolute_arrangement_indexes: Array[int] ## specifies fish shape with 1d indexes, the indexes are the absolute positions in the grid
var fish_parts: Array[FishPart]

## returns an array of fish parts that has a one-to-one mapping with the arrangement
func make_fish_parts() -> Array[FishPart]:
	if fish_parts.size() > 0:
		return fish_parts
	else:
		for i in arrangement.size():
			var vec = arrangement[i]
			var current_pos = vec * GS.GRID_SIZE
			var atlas_texture = AtlasTexture.new()
			atlas_texture.set_atlas(texture)
			atlas_texture.set_region(Rect2(current_pos, Vector2(GS.GRID_SIZE, GS.GRID_SIZE)))
			var fish_part = FishPart.new()
			fish_part.set_texture(atlas_texture)
			fish_part.set_parent_fish(self)
			fish_parts.append(fish_part)
		
		# inefficient but should be fine for sizes we are dealing with
		for i in arrangement.size():	
			var vec1 = arrangement[i]
			var fish_part1 = fish_parts[i]
			for j in range(i, arrangement.size()):
				var vec2 = arrangement[j]
				var fish_part2 = fish_parts[j]
				if vec1 + Vector2(0, -1) == vec2: # north
					fish_part1.adjacent_parts[0] = fish_part2
					fish_part2.adjacent_parts[2] = fish_part1
				elif vec1 + Vector2(1, 0) == vec2: # east
					fish_part1.adjacent_parts[1] = fish_part2
					fish_part2.adjacent_parts[3] = fish_part1
				elif vec1 + Vector2(0, 1) == vec2: # south
					fish_part1.adjacent_parts[2] = fish_part2
					fish_part2.adjacent_parts[0] = fish_part1
				elif vec1 + Vector2(-1, 0) == vec2: # west
					fish_part1.adjacent_parts[3] = fish_part2
					fish_part2.adjacent_parts[1] = fish_part1
					
			
		return fish_parts

func get_arrangement():
	return arrangement
	
func get_arrangement_indexes():
	var loc_arrangement_indexes: Array[int] = []
	for vec in arrangement:
		loc_arrangement_indexes.append(GS.grid_to_index(vec))
	return loc_arrangement_indexes

func get_absolute_arrangement_indexes():
	if absolute_arrangement_indexes.size() > 0:
		return absolute_arrangement_indexes
	else:
		return get_arrangement_indexes()

func set_absolute_arrangement_indexes(new_abs_arr_inds):
	absolute_arrangement_indexes = new_abs_arr_inds
