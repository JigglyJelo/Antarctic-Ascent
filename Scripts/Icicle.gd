class_name Icicle
extends CharacterBody2D
@onready var starting_x_pos: float = global_position.x

func _physics_process(_delta: float) -> void:
	if not is_on_floor():
		velocity.y = 100
	if velocity.y < 10 and is_in_group("death"):
		remove_from_group("death")
	elif velocity.y > 10 and not is_in_group("death"):
		add_to_group("death")
	if velocity.y > 100:
		velocity.y = 100
	if global_position.y > Game.camera.global_position.y + 300:
		queue_free()
	move_and_slide()
	for i in get_slide_collision_count():
		var collision:KinematicCollision2D = get_slide_collision(i)
		Game.build_tiles.destroy_tile(collision.get_position() - collision.get_normal(),false)
		destroy_ground_tile(collision.get_position() - collision.get_normal())
	if global_position.x != starting_x_pos:
		global_position.x = starting_x_pos
		
func destroy_ground_tile(global_point: Vector2) -> void:
	var cell: Vector2i = Game.build_tiles.ground_layer.local_to_map(Game.build_tiles.ground_layer.to_local(global_point))
	if Game.build_tiles.ground_layer.get_cell_tile_data(cell) != null:
		var surrounding_tiles: Array[Vector2i] = Game.build_tiles.ground_layer.get_surrounding_cells(cell)
		Game.build_tiles.ground_layer.erase_cell(cell)
		Game.build_tiles.rock_sfx.pitch_scale = randf_range(0.8,1.2)
		Game.build_tiles.rock_sfx.global_position = global_point
		Game.build_tiles.rock_sfx.play()
		for surrounding_tile: Vector2i in surrounding_tiles:
			if Game.build_tiles.ground_layer.get_cell_tile_data(surrounding_tile) != null:
				Game.build_tiles.ground_layer.erase_cell(surrounding_tile)
				Game.build_tiles.ground_layer.set_cells_terrain_connect([surrounding_tile],0,0,false)

#func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
#	for i: int in range(state.get_contact_count()):
#		Game.build_tiles.destroy_tile(state.get_contact_local_position(i),false) #LIAR FUNCTION IT ACTUALLY GIVES GLOBAL POSITION
