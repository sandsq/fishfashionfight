extends CenterContainer

signal can_be_dropped_signal

@export var display_debug_adjacents = false

var inventory = null
var associated_fish_part: FishPart
var icon_preview: TextureRect
var should_update_preview = false
var update_counter = 0
var empty_indicator = preload("res://assets/empty_indicator.png")
var Synergy = preload("res://synergy.tscn")
var provided_synergies = [null, null, null, null]
var hl_shader = preload("res://inventory/edge_highlight.gdshader")

#@onready var inventory = 
@onready var fish_part_texture_rect = $FishPartTextureRect
@onready var synergy_detector = $SynergyDetector
@onready var synergy_detector_shape = $SynergyDetector/CollisionShape2D

func _ready():
	synergy_detector.area_entered.connect(_on_synergy_detector_entered)
	synergy_detector.area_exited.connect(_on_synergy_detector_exited)

func _process(_delta):
	if should_update_preview:
		update_counter += 1
		if update_counter == 2:
			icon_preview.visible = true
			should_update_preview = false
			update_counter = 0

func display_fish_part(fish_part):
	if fish_part is FishPart:
		if display_debug_adjacents:
			for i in fish_part.adjacent_parts.size():
				var adjacent_part = fish_part.adjacent_parts[i]
				if adjacent_part == null:
					print("slot %s should have an empty indicator" % i)
					var indicator = Sprite2D.new()
					indicator.texture = empty_indicator
					indicator.modulate.a = 0.5
					var center_pos = 16
					var visual_offset = 8
					if i == 0:
						indicator.scale = Vector2(1, 0.5)
						indicator.set_position(
								Vector2(center_pos, center_pos-visual_offset))
					elif i == 1:
						indicator.scale = Vector2(0.5, 1)
						indicator.set_position(
								Vector2(center_pos+visual_offset, center_pos))
					elif i == 2:
						indicator.scale = Vector2(1, 0.5)
						indicator.set_position(
								Vector2(center_pos, center_pos+visual_offset))
					elif i == 3:
						indicator.scale = Vector2(0.5, 1)
						indicator.set_position(
								Vector2(center_pos-visual_offset, center_pos))
					self.add_child(indicator)
		fish_part_texture_rect.texture = fish_part.texture
		var testregion = fish_part_texture_rect.texture.region
		print("atlas region, for use in shader, pos %s, size %s" % [testregion.position, testregion.size])
		fish_part_texture_rect.material.shader = hl_shader
		fish_part_texture_rect.material.set_shader_parameter("edge", Plane(1, 1, 1, 1))
		fish_part_texture_rect.material.set_shader_parameter("atlas_pos", testregion.position)
		associated_fish_part = fish_part
		synergy_detector_shape.disabled = false
		for i in associated_fish_part.adjacent_synergies_to_provide.size():
			var synergy_to_provide = \
						associated_fish_part.adjacent_synergies_to_provide[i]
			#print("synergy to provide %s, index %s" % [synergy_to_provide, i])
			if synergy_to_provide != null:
				var synergy = GS.clone_synergy(synergy_to_provide)
				## duplicate doesn't duplicate variables
				#print("synergy data %s" % synergy.synergy_data)
				var synergy_collision_shape = CollisionShape2D.new()
				var synergy_shape = RectangleShape2D.new()
				#var indicator = ColorRect.new()
				#indicator.color = Color(1.0, 0, 0, 0.5)
				#print("synergy %s, synergy shape %s" 
						#% [synergy, synergy_shape])
				var center = Vector2(GS.GRID_SIZE / 2.0, GS.GRID_SIZE / 2.0)
				var offset = 18
				var horz_shape = Vector2(16, 4)
				var vert_shape = Vector2(4, 16)
				if i == 0:
					synergy_shape.size = horz_shape
					#indicator.custom_minimum_size = horz_shape
					synergy.set_position(center + Vector2(0, -offset))
					#indicator.set_position(center + Vector2(0, -offset))
				elif i == 1:
					synergy_shape.size = vert_shape
					#indicator.custom_minimum_size = vert_shape
					synergy.set_position(center + Vector2(offset, 0))
					#indicator.set_position(center + Vector2(offset, 0))
				elif i == 2:
					#indicator.custom_minimum_size = horz_shape
					#indicator.scale = Vector2(1, 0.5)
					synergy.set_position(center + Vector2(0, offset))
					#indicator.set_position(center + Vector2(0, offset))
				elif i == 3:
					synergy_shape.size = vert_shape
					#indicator.custom_minimum_size = vert_shape
					synergy.set_position(center + Vector2(-offset, 0))
					#indicator.set_position(center + Vector2(-offset, 0))
				
				synergy_collision_shape.shape = synergy_shape
				synergy.add_child(synergy_collision_shape)
				#self.add_child(indicator)
				provided_synergies[i] = synergy
				add_child(synergy)
				
	else:
		fish_part_texture_rect.texture = load(
				"res://assets/inventory_placeholder.png")
		fish_part_texture_rect.material.shader = hl_shader
		fish_part_texture_rect.material.set_shader_parameter("edge", Plane(0, 0, 0, 0))
		synergy_detector_shape.disabled = true
		for i in range(4):
			var provided_synergy = provided_synergies[i]
			if provided_synergy != null:
				remove_child(provided_synergy)


func _get_drag_data(_position):
	var fish_part_index = get_index()
	print("drag data index of fish part %s" % fish_part_index)
	if not associated_fish_part is FishPart:
		return
	var fish = associated_fish_part.get_parent_fish()
	print("drag data parent fish %s" % fish)
	var data = {}
	if fish is Entity:
		var relative_indexes = fish.get_arrangement_indexes()
		var absolute_indexes = fish.get_absolute_arrangement_indexes()
		print("absolute indexes when getting drag data %s" % [absolute_indexes])
		inventory.remove_fish_parts(absolute_indexes)
		
		
		icon_preview = TextureRect.new()
		icon_preview.texture = fish.texture
		icon_preview.visible = false
		#icon_preview.mouse_filter = MOUSE_FILTER_PASS
		var drag_preview = Control.new() # TextureRect.new()
		drag_preview.add_child(icon_preview)
		#drag_preview.mouse_filter = MOUSE_FILTER_PASS
		should_update_preview = true
		set_drag_preview(drag_preview)
		
		
		data.fish = fish
		data.fish_absolute_indexes = absolute_indexes
		data.fish_relative_indexes = relative_indexes
		
	inventory.drag_data = data
	return data

func _can_drop_data(_position, data):
	if data is Dictionary and data.has("fish"):
		var my_fish_part_index = get_index()
	
		#var fish_to_drop = data.fish
		#var fish_to_drop_abs_inds = data.fish_absolute_indexes
		var fish_to_drop_rel_inds = data.fish_relative_indexes
		
		var new_abs_inds = fish_to_drop_rel_inds.map(
				func(i): return i + my_fish_part_index)
		
		#print("calculating if something can be dropped here %s" 
				#% [new_abs_inds])
			
		for ind in new_abs_inds:
			if ind >= GS.INVENTORY_SIZE:
				emit_signal("can_be_dropped_signal", false)
				return false
				
			var potential_fish_part = inventory.get_fish_parts()[ind]
			if potential_fish_part is FishPart:
				var potential_fish = potential_fish_part.get_parent_fish()
				var potential_fish_abs_inds = \
						potential_fish.get_absolute_arrangement_indexes()
				#print("trying to drop into %s which already has a fish"
						#% [potential_fish_abs_inds])
				for ind2 in potential_fish_abs_inds:
					if new_abs_inds.has(ind2):
						emit_signal("can_be_dropped_signal", false)
						return false
		emit_signal("can_be_dropped_signal", true)	
		return true
	else:
		emit_signal("can_be_dropped_signal", false)
		return false


	
func _drop_data(_position, data):
	var my_fish_part_index = get_index()
	#var my_fish_part = inventory.fish_parts[my_fish_part_index]
	
	var relative_indexes_to_be_dropped = data.fish_relative_indexes
	var fish_to_be_dropped = data.fish
	var fish_parts_to_be_dropped = fish_to_be_dropped.make_fish_parts()
	
	var new_absolute_indexes_to_be_dropped: Array[int] = []
	for ind in relative_indexes_to_be_dropped:
		new_absolute_indexes_to_be_dropped.append(ind + my_fish_part_index)
	
	#if my_fish_part is FishPart:
		#var my_fish = my_fish_part.get_parent_fish()
	
	fish_to_be_dropped.set_absolute_arrangement_indexes(
			new_absolute_indexes_to_be_dropped)
			
	inventory.set_fish_parts(
			new_absolute_indexes_to_be_dropped, fish_parts_to_be_dropped)
	
	#print("after dropping, new inventory %s" % [inventory.get_fish_parts()])
	
	inventory.drag_data = null
		
		
func _on_synergy_detector_entered(area):
	
	var fish = associated_fish_part.get_parent_fish()
	var data = {"species": fish.species}
	print("potential candidate for synergy, I am index %s, the identity of the area is %s, the data is %s" % [get_index(), area, data])
	if area.synergy_condition.call(data):
		associated_fish_part.set_received_synergy_data(area.synergy_data)
	
func _on_synergy_detector_exited(_area):
	print("removing candidate for synergy, I am index %s" % [get_index()])
	associated_fish_part.set_received_synergy_data({})
