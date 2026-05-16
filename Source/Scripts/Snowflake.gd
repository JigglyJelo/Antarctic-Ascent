extends Area2D
@onready var sprite: Sprite2D = $Sprite2D
const SNOWFLAKE_SNOW: float = 10

func _process(delta: float) -> void:
	global_position.y += (delta / Game.camera.raise_speed) * 3

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		BuildingTiles.set_snow(BuildingTiles.snow+SNOWFLAKE_SNOW)
		Game.collect_sfx.pitch_scale = randf_range(0.9,1.1)
		Game.collect_sfx.global_position = global_position
		Game.collect_sfx.play()
		queue_free()
