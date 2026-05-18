class_name BuildingTiles

extends TileMapLayer
var delete_timer: int = 0
static var snow_label: Label
static var snow: float
const MAX_SNOW: float = 80
const SNOW_PLACE_COST: float = 1
const SNOW_ERASE_REFUND: float = 0.5
var place_sfx: AudioStreamPlayer2D
var erase_sfx: AudioStreamPlayer2D
var break_sfx: AudioStreamPlayer2D
var rock_sfx: AudioStreamPlayer2D
var ground_layer: TileMapLayer
var last_mouse_pos: Vector2
var last_action: int = 0 # 0 = None, 1 = Draw, 2 = Erase

func _ready() -> void:
	var parent: Node = get_parent()
	snow_label = parent.get_node("UICanvasLayer/SnowText")
	place_sfx = $PlaceSound
	erase_sfx = $EraseSound
	break_sfx = $BreakSound
	ground_layer = parent.get_node("GroundLayer")
	rock_sfx = ground_layer.get_node("RockBreakSound")
	set_snow(5)

func _process(_delta: float) -> void:
	if Game.player != null and Engine.time_scale < 1.01 and Engine.time_scale > 0.99 and Game.time > 0.5:
		tile_controls()
	#Clear offscreen tiles
	if delete_timer > 30:
		delete_timer = 0
		var tiles: Array[Vector2i] = get_used_cells()
		for tile: Vector2i in tiles:
			if to_global(map_to_local(tile)).y > Game.camera.global_position.y + 200:
				erase_cell(tile)
		var ground_tiles: Array[Vector2i] = ground_layer.get_used_cells()
		for tile: Vector2i in ground_tiles:
			if to_global(map_to_local(tile)).y > Game.camera.global_position.y + 200:
				erase_cell(tile)
		
	else:
		delete_timer += 1

func tile_controls() -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var current_action: int = 0
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		current_action = 1
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		current_action = 2
		
	if current_action == 0:
		last_action = 0
		return
		
	if current_action != last_action:
		last_mouse_pos = mouse_pos
		last_action = current_action
		
	var distance: float = last_mouse_pos.distance_to(mouse_pos)
	var steps: int = max(1, int(distance / 8.0))
	
	var processed_cells: Array[Vector2i] = []
	var cells_to_place: Array[Vector2i] = []
	var cells_to_erase: Array[Vector2i] = []
	
	for i in range(steps + 1):
		var step_pos: Vector2 = last_mouse_pos.lerp(mouse_pos, float(i) / float(steps))
		var cell: Vector2i = local_to_map(to_local(step_pos))
		
		if cell in processed_cells:
			continue
		processed_cells.append(cell)
		
		if current_action == 1: # DRAW
			if Game.player != null and step_pos.distance_squared_to(Game.player.global_position) > 225 and step_pos.x > -180 and step_pos.x < 180:
				if get_cell_tile_data(cell) == null and ground_layer.get_cell_tile_data(cell) == null:
					if snow - (cells_to_place.size() * SNOW_PLACE_COST) >= SNOW_PLACE_COST:
						cells_to_place.append(cell)
						
		elif current_action == 2: # ERASE
			if get_cell_tile_data(cell) != null:
				cells_to_erase.append(cell)
				
	# --- BATCH PROCESSING ---
	
	if cells_to_place.size() > 0:
		set_cells_terrain_connect(cells_to_place, 0, 0, true)
		set_snow(snow - (cells_to_place.size() * SNOW_PLACE_COST))
		
		place_sfx.pitch_scale = randf_range(0.8, 1.2)
		place_sfx.global_position = mouse_pos
		place_sfx.play()
		
	elif cells_to_erase.size() > 0:
		var surrounding_updates: Array[Vector2i] = []
		
		for cell in cells_to_erase:
			erase_cell(cell)
			
			# Gather surrounding tiles for autotile updates, avoiding duplicates
			var surrounding: Array[Vector2i] = get_surrounding_cells(cell)
			for s in surrounding:
				if get_cell_tile_data(s) != null and s not in cells_to_erase and s not in surrounding_updates:
					surrounding_updates.append(s)
		
		# Update the terrain for surrounding tiles once
		for s_cell in surrounding_updates:
			erase_cell(s_cell)
			set_cells_terrain_connect([s_cell], 0, 0, false)
			
		set_snow(snow + (cells_to_erase.size() * SNOW_ERASE_REFUND))
		
		erase_sfx.pitch_scale = randf_range(0.8, 1.2)
		erase_sfx.global_position = mouse_pos
		erase_sfx.play()
		
	last_mouse_pos = mouse_pos

static func set_snow(new_snow: float) -> void:
	if new_snow >= MAX_SNOW:
		Game.snow_flake_bonus += new_snow-MAX_SNOW
		BuildingTiles.snow = MAX_SNOW
		snow_label.self_modulate = Color(0,1,1)
	else:
		BuildingTiles.snow = new_snow
		snow_label.self_modulate = Color(1,1,1)
	snow_label.text = "Snow: " + str(BuildingTiles.snow)

func destroy_tile(global_point: Vector2, snow_regain: bool) -> void:
	var cell: Vector2i = local_to_map(to_local(global_point))
	if get_cell_tile_data(cell) != null:
		var surrounding_tiles: Array[Vector2i] = get_surrounding_cells(cell)
		erase_cell(cell)
		if snow_regain:
			set_snow(snow+SNOW_ERASE_REFUND)
			erase_sfx.pitch_scale = randf_range(0.8,1.2)
			erase_sfx.global_position = global_point
			erase_sfx.play()
		else:
			break_sfx.pitch_scale = randf_range(0.8,1.2)
			break_sfx.global_position = global_point
			break_sfx.play()
		for surrounding_tile: Vector2i in surrounding_tiles:
			if get_cell_tile_data(surrounding_tile) != null:
				erase_cell(surrounding_tile)
				set_cells_terrain_connect([surrounding_tile],0,0,false)

func start_game(body: Node2D) -> void:
	if body is Player:
		Game.started = true
		Game.camera.raise_speed = 0.15
		Game.snowflake_spawn_interval = 13
		Game.snowflake_next_spawn = Game.snowflake_spawn_interval
		Game.icicle_spawn_interval = 15
		Game.icicle_next_spawn = Game.icicle_spawn_interval
		get_parent().get_node("MusicPlayer").play()
		$StartArea.queue_free()

enum Pattern{
	PILLAR,PLUS,UP_LEFT_CORNER,LINE,DIAGANOL,RIGHT_ISLAND,ISLAND,LEFT_ISLAND,
	LEFT_LOOP,RIGHT_LOOP,FOUR_ISLAND,THREE_ISLAND,TWO_ISLAND,TPIECE,TRIPLE,ARCH,WALLS,BUCKET
}
