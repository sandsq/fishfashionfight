extends Resource
class_name Entity

@export var texture: Texture
@export var arrangement: Array[Vector2] ## specifies fish shape with 2d indexes

var absolute_arrangement_indexes: Array[int]

func make_fish_parts() -> Array[FishPart]:
	var fish_parts: Array[FishPart]
	fish_parts.resize(GS.INVENTORY_SIZE)
	fish_parts.fill(FishPart.new())
	for vec in arrangement:
		var current_pos = vec * GS.GRID_SIZE
		var current_index = GS.grid_to_index(vec)
		#print("grid index that has a fish part %s" % current_index)
		var atlas_texture = AtlasTexture.new()
		atlas_texture.set_atlas(texture)
		atlas_texture.set_region(Rect2(current_pos, Vector2(GS.GRID_SIZE, GS.GRID_SIZE)))
		var fish_part = FishPart.new()
		fish_part.set_texture(atlas_texture)
		fish_part.set_position(current_pos)
		fish_part.set_parent_fish(self)
		fish_parts[current_index] = fish_part
		#print(fish_part)
	#print(fish_parts)
	return fish_parts

func get_arrangement():
	return arrangement
	
func get_arrangement_indexes():
	var arrangement_indexes: Array[int]
	for vec in arrangement:
		arrangement_indexes.append(GS.grid_to_index(vec))
	return arrangement_indexes

func get_absolute_arrangement_indexes():
	if absolute_arrangement_indexes.size() > 0:
		return absolute_arrangement_indexes
	else:
		return get_arrangement_indexes()
