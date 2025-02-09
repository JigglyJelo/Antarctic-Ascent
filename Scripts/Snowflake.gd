extends Area2D
@onready var sprite: Sprite2D = $Sprite2D
const SNOWFLAKE_SNOW: float = 10

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position.y += (delta / Game.camera.raise_speed) * 3

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		#MAX_SNOW-SNOWFLAKE_SNOW = 30
		#if Game.build_tiles.snow > 30:
			#Game.snow_flake_bonus += int((Game.build_tiles.snow-30)/2)
			#Game.update_scores()
		BuildingTiles.set_snow(BuildingTiles.snow+SNOWFLAKE_SNOW)
		Game.collect_sfx.pitch_scale = randf_range(0.9,1.1)
		Game.collect_sfx.global_position = global_position
		Game.collect_sfx.play()
		queue_free()
