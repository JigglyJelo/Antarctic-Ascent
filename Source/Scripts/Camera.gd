class_name GameCamera
extends Camera2D
var raise_speed: float
var background: TextureRect

func _ready() -> void:
	background = get_parent().get_node("BGCanvasLayer/TextureRect")

func _process(delta: float) -> void:
	if not Player.dead and Game.started:
		position.y -= delta / raise_speed
		update_background(delta)
		Game.difficulty_increases(-position.y)
		
func update_background(delta: float) -> void:
	#Specific updates
	if background.position.y < -180:
		background.position.y += delta * 15
