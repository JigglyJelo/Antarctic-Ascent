class_name Player
extends CharacterBody2D

#Controls Variables
const SPEED: float = 10
const MAX_SPEED: float = 175
const JUMP_VELOCITY: float = -350.0
const JUMP_BUFFER: int = 6
const COYOTE_TIME: int = 6
var jump_buffer: int = 0
var coyote_time: int = 0
const GRAVITY: float = 15
const TERMINAL_VELOCITY: float = 360
#Nodes
var sprite: AnimatedSprite2D
var clone_sprite: AnimatedSprite2D
var jump_sfx: AudioStreamPlayer2D
var bounce_sfx: AudioStreamPlayer2D
#Gameplay Variables
static var dead: bool = false

func _ready() -> void:
	dead = false
	sprite = $PlayerSprite
	clone_sprite = $CloneSprite
	jump_sfx = $JumpSound
	bounce_sfx = $BounceSound

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pause()
	#Gravity and Coyote Time
	if not is_on_floor():
		velocity.y += GRAVITY
		if velocity.y > TERMINAL_VELOCITY:
			velocity.y = TERMINAL_VELOCITY
		if coyote_time > 0:
			coyote_time -= 1
	elif coyote_time != COYOTE_TIME:
		coyote_time = COYOTE_TIME
	#Jump Buffer
	if Input.is_action_just_pressed("jump") and jump_buffer == 0:
		jump_buffer = JUMP_BUFFER
	elif jump_buffer > 0:
		jump_buffer -= 1
	#Jump
	if (Input.is_action_just_pressed("jump") or jump_buffer > 0) and (is_on_floor() or coyote_time > 0):
		jump()
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = 0
	#Horizontal Movement
	if Engine.time_scale < 1.01 and Engine.time_scale > 0.99:
		position.x += Game.wind * Game.wind_direction
	if Input.is_action_pressed("left"):
		if velocity.x > MAX_SPEED/2:
			velocity.x = MAX_SPEED/2
		velocity.x -= SPEED
		if velocity.x < -MAX_SPEED:
			velocity.x = -MAX_SPEED
	elif Input.is_action_pressed("right"):
		if velocity.x < (-MAX_SPEED)/2:
			velocity.x = (-MAX_SPEED)/2
		velocity.x += SPEED
		if velocity.x > MAX_SPEED:
			velocity.x = MAX_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED*2)
	move_and_slide()
	#Die offscreen
	if global_position.y > Game.camera.global_position.y + 200:
		die()
	if not is_on_floor() and velocity.y > 0 and sprite.animation != "fall":
		sprite.animation = "fall"
		sprite.play()
	#Scoring
	const START_OFFSET: int = 150
	if -global_position.y+START_OFFSET > Game.height:
		Game.set_height(-global_position.y+START_OFFSET)
	#Screen wrap around stuff
	#Put clone in correct position
	if global_position.x > 0 and clone_sprite.global_position.x > 0:
		clone_sprite.position.x *= -1
		reset_physics_interpolation()
	elif  global_position.x < 0 and clone_sprite.global_position.x < 0:
		clone_sprite.position.x *= -1
		reset_physics_interpolation()
	#Check for screen wrap
	if global_position.x > 172 or global_position.x < -172:
		#Sync clone animation
		clone_sprite.flip_h = sprite.flip_h
		if clone_sprite.animation != sprite.animation:
			clone_sprite.animation = sprite.animation
			clone_sprite.frame = sprite.frame
			clone_sprite.play()
		#Screen wrap around
		if global_position.x > 180:
			global_position.x = -180
			clone_sprite.position.x *= -1
		elif global_position.x < -180:
			global_position.x = 180
			clone_sprite.position.x *= -1
		reset_physics_interpolation()
	elif clone_sprite.is_playing():
		clone_sprite.stop()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("right"):
		sprite.flip_h = false
	elif Input.is_action_just_pressed("left"):
		sprite.flip_h = true
		
	if is_on_floor():
		if velocity.is_zero_approx() and sprite.animation != "idle":
			sprite.animation = "idle"
			sprite.play()
		elif not velocity.is_zero_approx() and sprite.animation != "walk":
			sprite.animation = "walk"
			sprite.play()

func jump() -> void:
	sprite.play("jump")
	jump_sfx.pitch_scale = randf_range(1.5,1.75)
	jump_sfx.play()
	velocity.y = JUMP_VELOCITY
	coyote_time = 0
	jump_buffer = 0

func die() -> void:
	var parent: Node = get_parent()
	parent.get_node("MusicPlayer").stop()
	parent.get_node("Cursor").queue_free()
	if Game.snow_flake_bonus > 0:
		var bonus_text: Label = Game.UICanvasLayer.get_node("BonusText")
		bonus_text.text += str(Game.snow_flake_bonus)
		bonus_text.visible = true
	Game.death_sfx.play()
	dead = true
	Game.UICanvasLayer.get_node("Deathscreen").position.x = 0
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	collision_checks(body)

func _on_area_2d_area_entered(area: Area2D) -> void:
	collision_checks(area)

func collision_checks(node: Node) -> void:
	if node.is_in_group("death") and global_position.y > Game.camera.global_position.y - 210:
		if node is Icicle:
			const ICICLE_OFFSET: int = 35
			if global_position.y > node.global_position.y - ICICLE_OFFSET:
				die()
		else:
			die()
	elif node.is_in_group("bouncy"):
		bounce_sfx.play()
		if Input.is_action_pressed("jump"):
			velocity.y = -500
		else:
			velocity.y = -250
	elif node.is_in_group("stop"):
		if velocity.y < 0:
			velocity.y /= 3

func pause() -> void:
	if Engine.time_scale < 1.01 and Engine.time_scale > 0.99:
		Engine.time_scale = 0
		Game.UICanvasLayer.get_node("Pausescreen").position.x = 0
	else:
		Engine.time_scale = 1
		Game.UICanvasLayer.get_node("Pausescreen").position.x = 720
