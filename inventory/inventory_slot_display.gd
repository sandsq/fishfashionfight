extends CenterContainer

signal can_be_dropped_signal
signal mouse_hovered_over_synergy(data)
signal mouse_hovered_over_fish_part(data)


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
var shader_edges = Plane(0, 0, 0, 0)

#@onready var inventory = 
@onready var fish_part_texture_rect = $FishPartTextureRect
@onready var synergy_detector = $SynergyDetector
@onready var synergy_detector_shape = $SynergyDetector/CollisionShape2D
@onready var info_detector_shape = $InfoDetector/CollisionShape2D

func _ready():
	synergy_detector.area_entered.connect(_on_synergy_detector_entered)
	synergy_detector.area_exited.connect(_on_synergy_detector_exited)
	#synergy_detector.mouse_entered.connect(_on_synergy_detector_mouse_entered)
	

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
		
		associated_fish_part = fish_part
		synergy_detector_shape.disabled = false
		info_detector_shape.disabled = false
		for i in associated_fish_part.adjacent_synergies_to_provide.size():
			var synergy_to_provide = \
						associated_fish_part.adjacent_synergies_to_provide[i]
			#print("synergy to provide %s, index %s" % [synergy_to_provide, i])
			if synergy_to_provide != null:
				## duplicate doesn't duplicate variables
				var synergy = GS.clone_synergy(synergy_to_provide)
				synergy.mouse_entered.connect(_on_mouse_entered_synergy_zone
						.bind(synergy.synergy_data))
				#synergy.mouse_exited.connect(_on_mouse_entered_synergy_zone
						#.bind({}))
				synergy.attached_to = self 
				var synergy_collision_shape = CollisionShape2D.new()
				var synergy_shape = RectangleShape2D.new()
				
				var center = Vector2(GS.GRID_SIZE / 2.0, GS.GRID_SIZE / 2.0)
				var offset = 12
				var horz_shape = Vector2(16, 12)
				var vert_shape = Vector2(12, 16)
				var texture_region = fish_part_texture_rect.texture.region
				var inactive_colors: Array[Plane] = [GS.inactive_synergy_color, GS.inactive_synergy_color, GS.inactive_synergy_color, GS.inactive_synergy_color]
				#print("atlas region, for use in shader, pos %s, size %s" 
						#% [texture_region.position, texture_region.size])
				var single_edge_info = Plane() # if a move happened that only activates one synergy, only show that synergy
				if i == 0:
					synergy_shape.size = horz_shape
					synergy.set_position(center + Vector2(0, -offset))
					single_edge_info = Plane(1, 0, 0, 0)
					shader_edges = Plane(shader_edges.x + 1, shader_edges.y, shader_edges.z, shader_edges.d) # ensure all edges of a fish get indicated
					print("about to create shader for slot %s, synergy %s, synergy shape %s, data %s, on side %s" % [get_index(), synergy, synergy_shape, synergy.synergy_data, i])
					create_shader(fish_part_texture_rect, shader_edges, 
							inactive_colors, texture_region.position)
				elif i == 1:
					synergy_shape.size = vert_shape
					synergy.set_position(center + Vector2(offset, 0))
					shader_edges = Plane(shader_edges.x, shader_edges.y + 1, shader_edges.z, shader_edges.d)
					single_edge_info = Plane(0, 1, 0, 0)
					print("about to create shader for slot %s, synergy %s, synergy shape %s, data %s, on side %s" % [get_index(), synergy, synergy_shape, synergy.synergy_data, i])
					create_shader(fish_part_texture_rect, shader_edges, 
							inactive_colors, texture_region.position)
					
				elif i == 2:
					single_edge_info = Plane(0, 0, 1, 0)
					synergy_shape.size = horz_shape
					synergy.set_position(center + Vector2(0, offset))
					shader_edges = Plane(shader_edges.x, shader_edges.y, shader_edges.z + 1, shader_edges.d)
					print("about to create shader for slot %s, synergy %s, synergy shape %s, data %s, on side %s" % [get_index(), synergy, synergy_shape, synergy.synergy_data, i])
					
					create_shader(fish_part_texture_rect, shader_edges, 
							inactive_colors, texture_region.position)
				elif i == 3:
					synergy_shape.size = vert_shape
					synergy.set_position(center + Vector2(-offset, 0))
					single_edge_info = Plane(0, 0, 0, 1)
					shader_edges = Plane(shader_edges.x, shader_edges.y, shader_edges.z, shader_edges.d + 1)
					print("about to create shader for slot %s, synergy %s, synergy shape %s, data %s, on side %s" % [get_index(), synergy, synergy_shape, synergy.synergy_data, i])
					create_shader(fish_part_texture_rect, shader_edges, 
							inactive_colors, texture_region.position)
				
				synergy_collision_shape.shape = synergy_shape
				#synergy.area_entered.connect(_on_synergy_hitbox_hit_something)
				#synergy.area_exited.connect(_on_synergy_hitbox_left_something)
				synergy.add_child(synergy_collision_shape)
				#self.add_child(indicator)
				provided_synergies[i] = synergy
				synergy.edge_info = single_edge_info
				add_child(synergy)
				
	else:
		fish_part_texture_rect.texture = load(
				"res://assets/inventory_placeholder.png")
		fish_part_texture_rect.material.shader = hl_shader
		fish_part_texture_rect.material.set_shader_parameter("edge", Plane(0, 0, 0, 0))
		synergy_detector_shape.disabled = true
		info_detector_shape.disabled = true
		shader_edges = Plane(0, 0, 0, 0)
		for i in range(4):
			var provided_synergy = provided_synergies[i]
			if provided_synergy != null:
				remove_child(provided_synergy)
				provided_synergy.queue_free()

func create_shader(obj, edge: Plane, colors: Array[Plane], atlas_position: Vector2):
	obj.material.shader = hl_shader
	obj.material.set_shader_parameter("edge", edge)
	obj.material.set_shader_parameter("top_hl_color", colors[0])
	obj.material.set_shader_parameter("right_hl_color", colors[1])
	obj.material.set_shader_parameter("bottom_hl_color", colors[2])
	obj.material.set_shader_parameter("left_hl_color", colors[3])
	obj.material.set_shader_parameter("atlas_pos", atlas_position)

func set_colors_cascading(obj, edge: Plane, color=GS.active_synergy_color):
	
	if edge.x >= 0.99: # top flag
		print("setting top color %s" % color)
		obj.material.set_shader_parameter("top_hl_color", color)
	#else:
		#obj.material.set_shader_parameter("top_hl_color", GS.inactive_synergy_color)
	if edge.y >= 0.99: # right flag
		print("setting right color %s" % color)
		obj.material.set_shader_parameter("right_hl_color", color)
	#else:
		#obj.material.set_shader_parameter("right_hl_color", GS.inactive_synergy_color)
	if edge.z >= 0.99: # bottom flag
		print("setting bottom color %s" % color)
		obj.material.set_shader_parameter("bottom_hl_color", color)
	#else:
		#obj.material.set_shader_parameter("bottom_hl_color", GS.inactive_synergy_color)
	if edge.d >= 0.99: # left flag
		print("setting left color %s" % color)
		obj.material.set_shader_parameter("left_hl_color", color)
	#else:
		#obj.material.set_shader_parameter("left_hl_color", GS.inactive_synergy_color)

		
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
		
		var drag_preview = Control.new()
		
		icon_preview = TextureRect.new()
		icon_preview.texture = fish.texture
		icon_preview.visible = false
		icon_preview.material = ShaderMaterial.new()
		icon_preview.scale = Vector2(2.0, 2.0)
		icon_preview.position = Vector2(-32, -32)
		#create_shader(icon_preview, Plane(1, 1, 1, 1), Plane(1.0, 0.5, 0.4, 0.5), Vector2.ZERO)
		drag_preview.add_child(icon_preview)
	
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

func plane_to_index(p: Plane):
	if p.x >= 0.99:
		return 0
	if p.y >= 0.99:
		return 1
	if p.z >= 0.99:
		return 2
	if p.d >= 0.99:
		return 3
		
func _on_synergy_detector_entered(area):
	if area.attached_to == self:
		print("intersecting with self, don't do anything")
		return
	if area == null:
		print("intersecting area is null, something wrong o.o")
		return
	if area.synergy_condition == null:
		print("synergy condition null, something wrong o.o")
		return
	var fish = associated_fish_part.get_parent_fish()
	var data = {"species": fish.species}
	if area.synergy_condition.call(data):
		print("potential candidate for synergy, I am index %s, the identity of the area is %s, the data is %s" % [get_index(), area, data])
		set_colors_cascading(area.attached_to.fish_part_texture_rect, area.edge_info)
		associated_fish_part.set_received_synergy_data(area.synergy_data, plane_to_index(area.edge_info))
	
func _on_synergy_detector_exited(area):
	print("removing candidate for synergy, I am index %s" % [get_index()])
	#for s in associated_fish_part.received_synergy_data:
		#print(area.edge_info)
	set_colors_cascading(area.attached_to.fish_part_texture_rect, area.edge_info, GS.inactive_synergy_color)
	associated_fish_part.set_received_synergy_data({}, plane_to_index(area.edge_info))

func _on_mouse_entered_synergy_zone(synergy_data):
	#print("show tooltip here %s" % [synergy_data])
	emit_signal("mouse_hovered_over_synergy", synergy_data)
	



func _on_info_detector_mouse_entered():
	#print("mouse entered info detector")
	emit_signal("mouse_hovered_over_fish_part", associated_fish_part)
