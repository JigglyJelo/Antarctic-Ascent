extends StaticBody2D
var sprite: AnimatedSprite2D
static var snowball_scene: PackedScene
var throw_timer = 0
static var throw_interval = 1

func _ready() -> void:
	if snowball_scene == null:
		snowball_scene = load("res://Scenes/Snowball.tscn")
	sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if global_position.y > Game.camera.global_position.y + 300:
		queue_free()
		return
	throw_timer += delta
	if Game.player == null:
		return
	if throw_timer > throw_interval and sprite.animation != "throw" and Game.player != null and Game.player.global_position.distance_squared_to(global_position) < 40000 and global_position.y > Game.camera.global_position.y - 180:
		sprite.animation = "throw"
		sprite.play()
	if Game.player.global_position.x > global_position.x and not sprite.flip_h:
		sprite.flip_h = true
	elif Game.player.global_position.x < global_position.x and sprite.flip_h:
		sprite.flip_h = false
		
func throw_snowball() -> void:
	throw_timer = 0
	if Game.player == null:
		return
	var snowball: RigidBody2D = snowball_scene.instantiate()
	#Get angle to throw snow ball which will be angle between snowman and slightly above player to account for gravity
	var angle: float = atan2(((Game.player.global_position.y-15)-global_position.y),(Game.player.global_position.x-global_position.x))
	snowball.apply_force(Vector2.from_angle(angle)*2000)
	add_child(snowball)

func _on_animated_sprite_2d_frame_changed() -> void:
	if sprite.animation == "throw":
		match sprite.frame:
			2:
				throw_snowball()
			4:
				sprite.animation = "default"
