extends RigidBody2D

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var contact_count: int = state.get_contact_count()
	#print(contact_count)
	for i: int in range(contact_count):
		Game.build_tiles.destroy_tile(state.get_contact_local_position(i),false) #LIAR FUNCTION IT ACTUALLY GIVES GLOBAL POSITION
		var collider: Object = state.get_contact_collider_object(i)
		if collider.is_in_group("player"):
			var angle: float = atan2((Game.player.global_position.y-global_position.y),(Game.player.global_position.x-global_position.x))
			var player: CharacterBody2D = (collider as CharacterBody2D)
			player.velocity += Vector2(cos(angle),sin(angle))*200
	if contact_count > 0:
		Game.build_tiles.erase_sfx.pitch_scale = randf_range(0.8,1.2)
		Game.build_tiles.erase_sfx.global_position = global_position
		Game.build_tiles.erase_sfx.play()
		queue_free()
