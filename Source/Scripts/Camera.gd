class_name GameCamera
extends Camera2D
var raise_speed: float
var background: TextureRect

func _ready() -> void:
	background = get_parent().get_node("BGCanvasLayer/TextureRect")

func _process(delta: float) -> void:
	if not Player.dead and Game.started:
		var speed_multiplier: float = position_speed_multiplier()
		position.y -= (delta * speed_multiplier) / raise_speed
		update_background(delta*speed_multiplier)
		Game.difficulty_increases(-position.y)
		
func update_background(delta: float) -> void:
	#Specific updates
	if background.position.y < -180:
		background.position.y += delta * 15

func position_speed_multiplier() -> float:
	const TIER_1_THRESHOLD: float = 66.67
	const TIER_2_THRESHOLD: float = 75.0
	const TIER_3_THRESHOLD: float = 105
	
	const TIER_1_SPEED: float = 1.25
	const TIER_2_SPEED: float = 1.5
	const TIER_3_SPEED: float = 2
	
	var player_y: float = Game.player.global_position.y
	var camera_y: float = global_position.y
	var viewport_height: float = get_viewport_rect().size.y
	
	var bottom_edge: float = camera_y + (viewport_height / 2.0)
	var screen_percentage: float = ((bottom_edge - player_y) / viewport_height) * 100.0
	
	print("Player Position: ", round(screen_percentage), "%")
	
	# Height checks
	if screen_percentage < TIER_1_THRESHOLD: # 0% to 66%
		return 1.0
	elif screen_percentage < TIER_2_THRESHOLD: # 66.67% to 74.9%
		return TIER_1_SPEED
	elif screen_percentage < TIER_3_THRESHOLD: # 75% and above
		return TIER_2_SPEED
	else:
		return TIER_3_SPEED

""" Unused linear speed multiplier
func position_speed_multiplier() -> float:
	const THRESHOLD_PCT: float = 75
	const MAX_SPEED_INCREASE: float = 0.6
	var player_y: float = Game.player.global_position.y
	var camera_y: float = global_position.y
	var viewport_height: float = get_viewport_rect().size.y
	var bottom_edge: float = camera_y + (viewport_height / 2.0)
	var screen_percentage: float = ((bottom_edge - player_y) / viewport_height) * 100.0
	print("Player Position: ", round(screen_percentage), "%")
	if screen_percentage <= THRESHOLD_PCT: # In bottom 2/3 of screen
		return 1.0
	else:
		# Calculate how many percentage points the player is past the threshold
		var current_excess: float = screen_percentage - THRESHOLD_PCT
		# Calculate the maximum possible percentage points past the threshold
		var max_excess: float = 100.0 - THRESHOLD_PCT
		# Create a 0.0 to 1.0 ratio of how far they are into that top section
		var ratio: float = current_excess / max_excess
		# Apply the ratio to your maximum speed increase
		print("Ratio: ", ratio, "%")
		return 1.0 + (ratio * MAX_SPEED_INCREASE)
"""
