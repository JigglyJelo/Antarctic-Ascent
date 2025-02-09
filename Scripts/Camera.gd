class_name GameCamera
extends Camera2D
var raise_speed: float
static var height_label: Label
static var highscore_label: Label
var background: TextureRect
var background_gradient: Gradient

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	height_label = $HeightText
	highscore_label = $HighscoreText
	background = $TextureRect
	background_gradient = (background.texture as GradientTexture2D).gradient
	@warning_ignore("integer_division")
	highscore_label.text = "Highscore: " + str(int(Game.highscore/15)) + "M"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if not Player.dead:
	#	position.y -= delta * 2
	if not Player.dead and Game.started:
		position.y -= delta / raise_speed
		update_background(delta)
		Game.difficulty_increases(-position.y)
		
func update_background(delta: float) -> void:
	#Specific updates
	if background.position.y < -180:
		background.position.y += delta * 15
		pass
