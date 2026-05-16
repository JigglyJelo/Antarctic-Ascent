class_name Game
extends Node
static var player: Player
static var camera: GameCamera
static var build_tiles: BuildingTiles
static var height: float
static var snow_flake_bonus: float
static var time: float
static var snowflake_scene: PackedScene
static var snowflake_timer: float
static var snowflake_spawn_interval: float
static var snowflake_next_spawn: float
static var icicle_scene: PackedScene
static var icicle_timer: float
static var icicle_next_spawn: float
static var icicle_spawn_interval: float
static var cloud_scene: PackedScene
static var cloud_timer: float
static var cloud_spawn_interval: float
static var cloud_next_spawn: float
static var storm_cloud_scene: PackedScene
static var storm_timer: float
static var storm_spawn_interval: float
static var storm_next_spawn: float
static var snowman_scene: PackedScene
static var snowman_timer: float
static var snowman_spawn_interval: float
static var snowman_next_spawn: float
static var star_scene: PackedScene
static var star_timer: float
static var star_spawn_interval: float
static var star_next_spawn: float
static var death_sfx: AudioStreamPlayer
static var wind_sfx: AudioStreamPlayer
static var collect_sfx: AudioStreamPlayer2D
static var music: AudioStreamPlayer
static var wind: float
static var wind_direction: int
static var difficulty: int
static var pattern_timer: float
static var pattern_spawn_interval: float
static var pattern_next_spawn: float
static var possible_patterns: Array[BuildingTiles.Pattern]
static var highscore: int
static var started: bool
static var music_volume: float
static var sfx_volume: float
const SAVE_PATH: String = "user://Ascent.save"
const SETTINGS_PATH: String = "user://Settings.save"
const MENU_MUSIC_SECONDS: float = 140.909210205078

func _ready() -> void:
	started = false
	music = $MusicPlayer
	$Snowflake.global_position.x = randf_range(-152,152)
	death_sfx = $DeathSound
	player = $Player
	camera = $Camera2D
	build_tiles = $TileMapLayer
	wind_sfx = $WindSound
	collect_sfx = $CollectSound
	height = 0
	snow_flake_bonus = 0
	camera.raise_speed = INF
	if icicle_scene == null:
		icicle_scene = preload("res://Source/Scenes/Object Scenes/Icicle.tscn")
		snowflake_scene = preload("res://Source/Scenes/Object Scenes/Snowflake.tscn")
		cloud_scene = preload("res://Source/Scenes/Object Scenes/SmallCloud.tscn")
		storm_cloud_scene = preload("res://Source/Scenes/Object Scenes/StormCloud.tscn")
		snowman_scene = preload("res://Source/Scenes/Object Scenes/Snowman.tscn")
		star_scene = preload("res://Source/Scenes/Object Scenes/Star.tscn")
	icicle_timer = 0
	icicle_spawn_interval = INF
	icicle_next_spawn = icicle_spawn_interval
	snowflake_timer = 0
	snowflake_spawn_interval = INF
	snowflake_next_spawn = snowflake_spawn_interval
	cloud_timer = 0
	cloud_spawn_interval = INF
	cloud_next_spawn = cloud_spawn_interval
	snowman_timer = 0
	snowman_spawn_interval = INF
	snowman_next_spawn = snowman_spawn_interval
	storm_timer = 0
	storm_spawn_interval = INF
	storm_next_spawn = storm_spawn_interval
	star_timer = 0
	star_spawn_interval = INF
	star_next_spawn = star_spawn_interval
	spawn_snowflake()
	wind = 0
	wind_direction = 1 if randi_range(0,1) == 0 else -1
	difficulty = 0
	pattern_timer = 0
	pattern_spawn_interval = 45
	pattern_next_spawn = pattern_spawn_interval
	possible_patterns = [BuildingTiles.Pattern.FOUR_ISLAND,BuildingTiles.Pattern.THREE_ISLAND,BuildingTiles.Pattern.TWO_ISLAND]
	spawn_pattern()
	if is_equal_approx(music.stream.get_length(),MENU_MUSIC_SECONDS):
		pass
	else:
		music.stop()

func _process(delta: float) -> void:
	if (wind > 0.01 or wind < -0.01) and not wind_sfx.playing:
		wind_sfx.play()
	elif wind < 0.01 and wind > -0.01 and wind_sfx.playing:
		wind_sfx.stop()
	time += delta
	if Game.started:
		icicle_timer += delta
		if icicle_timer >= icicle_next_spawn:
			icicle_timer = 0
			icicle_next_spawn = randf_range(icicle_spawn_interval*0.8,icicle_spawn_interval*1.2)
			#8.5
			spawn_icicle()
		snowflake_timer += delta
		if snowflake_timer >= snowflake_next_spawn:
			snowflake_timer = 0
			snowflake_next_spawn = randf_range(snowflake_spawn_interval*0.8,snowflake_spawn_interval*1.2)
			spawn_snowflake()
	if difficulty > 0:
		cloud_timer += delta
		if cloud_timer >= cloud_next_spawn:
			cloud_timer = 0
			cloud_next_spawn = randf_range(cloud_spawn_interval*0.8,cloud_spawn_interval*1.2)
			spawn_cloud()
		snowman_timer += delta
		if snowman_timer >= snowman_next_spawn:
			snowman_timer = 0
			snowman_next_spawn = randf_range(snowman_spawn_interval*0.8,snowman_spawn_interval*1.2)
			spawn_snowman()
	if difficulty > 5:
		storm_timer += delta
		if storm_timer >= storm_next_spawn:
			storm_timer = 0
			storm_next_spawn = randf_range(storm_spawn_interval*0.8,storm_spawn_interval*1.2)
			spawn_storm()
	if difficulty >= 15:
		star_timer += delta
		if star_timer >= star_next_spawn:
			star_timer = 0
			star_next_spawn = randf_range(star_spawn_interval*0.8,star_spawn_interval*1.2)
			spawn_star()
	pattern_timer += delta
	if pattern_timer >= pattern_next_spawn:
		pattern_timer = 0
		pattern_next_spawn = randf_range(pattern_spawn_interval*0.8,pattern_spawn_interval*1.2)
		spawn_pattern()

static func set_height(new_height: float) -> void:
	if height < new_height:
		height = new_height
		#update_scores()
		camera.height_label.text = "Height: " + str(int(height/15)) + "M"
		if height > highscore:
			@warning_ignore("narrowing_conversion")
			highscore = height
			save_highscore()
			@warning_ignore("integer_division")
			camera.highscore_label.text = "Hiscore: " + str(int(highscore/15)) + "M"

func spawn_icicle() -> void:
	if player != null:
		var icicle: Icicle = icicle_scene.instantiate()
		icicle.global_position = Vector2(player.global_position.x,camera.global_position.y-285)
		add_child(icicle)

func spawn_snowflake() -> void:
	var snowflake: Area2D = snowflake_scene.instantiate()
	snowflake.global_position = Vector2(randi_range(-158,158),camera.global_position.y-212)
	add_child(snowflake)

func spawn_cloud() -> void:
	var cloud: Sprite2D = cloud_scene.instantiate()
	cloud.global_position = Vector2(randi_range(-116,116),camera.global_position.y-212)
	add_child(cloud)

func spawn_snowman() -> void:
	var snowman: StaticBody2D = snowman_scene.instantiate()
	snowman.global_position = Vector2(randi_range(-148,148),camera.global_position.y-212)
	add_child(snowman)

func spawn_storm() -> void:
	var storm: Sprite2D = storm_cloud_scene.instantiate()
	storm.global_position = Vector2(randi_range(-116,116),camera.global_position.y-212)
	add_child(storm)

func spawn_star():
	var star: Sprite2D = star_scene.instantiate()
	star.global_position = Vector2(randi_range(-148,148),camera.global_position.y-212)
	add_child(star)

func spawn_pattern() -> void:
	var pattern_id: BuildingTiles.Pattern = possible_patterns.pick_random()
	match pattern_id:
		BuildingTiles.Pattern.LEFT_LOOP:
			var pattern: TileMapPattern = build_tiles.ground_layer.tile_set.get_pattern(BuildingTiles.Pattern.LEFT_LOOP)
			var y_pos: float = camera.global_position.y-257
			var tiled_position: Vector2i = build_tiles.ground_layer.local_to_map(build_tiles.ground_layer.to_local(Vector2(-180,y_pos)))
			build_tiles.ground_layer.set_pattern(tiled_position,pattern)
		BuildingTiles.Pattern.RIGHT_LOOP:
			var pattern: TileMapPattern = build_tiles.ground_layer.tile_set.get_pattern(BuildingTiles.Pattern.RIGHT_LOOP)
			var y_pos: float = camera.global_position.y-257
			var tiled_position: Vector2i = build_tiles.ground_layer.local_to_map(build_tiles.ground_layer.to_local(Vector2(-180,y_pos)))
			build_tiles.ground_layer.set_pattern(tiled_position,pattern)
		_:
			var pattern: TileMapPattern = build_tiles.ground_layer.tile_set.get_pattern(pattern_id)
			var pattern_size: Vector2 = pattern.get_size()
			@warning_ignore("narrowing_conversion")
			var x_length: int = pattern_size.x * 15
			@warning_ignore("narrowing_conversion")
			var y_length: int = pattern_size.y * 15
			var x_pos: int = randi_range(-180+x_length,180-x_length)
			@warning_ignore("narrowing_conversion")
			var y_pos: int = camera.global_position.y-212-y_length
			var tiled_position: Vector2i = build_tiles.ground_layer.local_to_map(build_tiles.ground_layer.to_local(Vector2(x_pos,y_pos)))
			build_tiles.ground_layer.set_pattern(tiled_position,pattern)

static func difficulty_increases(distance: float) -> void:
	#Height in tiles times their size (15)
	match difficulty:
		0:
			if distance >= 150:
				camera.raise_speed = 0.125
				snowflake_spawn_interval *= 1-(0.15-camera.raise_speed)
				difficulty = 1
		1:
			if distance >= 225:
				camera.raise_speed = 0.1
				snowflake_spawn_interval *= 1-(0.125-camera.raise_speed)
				cloud_spawn_interval = 10
				cloud_next_spawn = randf_range(cloud_spawn_interval*0.8,cloud_spawn_interval*1.2)
				difficulty = 2
		2:
			if distance >= 300: #Ground gone
				camera.raise_speed = 0.09
				snowflake_spawn_interval *= 1-(0.1-camera.raise_speed)
				cloud_spawn_interval = 12
				cloud_next_spawn = randf_range(cloud_spawn_interval*0.8,cloud_spawn_interval*1.2)
				icicle_spawn_interval = 10
				icicle_next_spawn = randf_range(icicle_spawn_interval*0.8,icicle_spawn_interval*1.2)
				snowman_spawn_interval = 60
				snowman_next_spawn = randf_range(snowman_spawn_interval*0.8,snowman_spawn_interval*1.2)
				difficulty = 3
		3:
			if distance >= 405:
				camera.raise_speed = 0.08
				snowflake_spawn_interval *= 1-(0.09-camera.raise_speed)
				difficulty = 4
		4: 
			if distance >= 525:
				camera.raise_speed = 0.07
				snowflake_spawn_interval *= 1-(0.08-camera.raise_speed)
				cloud_spawn_interval = 15
				cloud_next_spawn = randf_range(cloud_spawn_interval*0.8,cloud_spawn_interval*1.2)
				difficulty = 5
		5:
			if distance >= 600: #Pure sky
				camera.raise_speed = 0.06
				snowflake_spawn_interval *= 1-(0.07-camera.raise_speed)
				pattern_spawn_interval = 40
				pattern_next_spawn = randf_range(pattern_spawn_interval*0.8,pattern_spawn_interval*1.2)
				snowman_spawn_interval = 45
				snowman_next_spawn = randf_range(snowman_spawn_interval*0.8,snowman_spawn_interval*1.2)
				difficulty = 6
		6:
			if distance >= 750:
				camera.raise_speed = 0.055
				snowflake_spawn_interval *= 1-(0.06-camera.raise_speed)
				cloud_spawn_interval = 17.5
				cloud_next_spawn = randf_range(cloud_spawn_interval*0.8,cloud_spawn_interval*1.2)
				difficulty = 7
				possible_patterns = [BuildingTiles.Pattern.FOUR_ISLAND,BuildingTiles.Pattern.THREE_ISLAND,BuildingTiles.Pattern.PLUS]
		7:
			if distance >= 900:
				snowflake_spawn_interval *= 1-(0.05-camera.raise_speed)
				camera.raise_speed = 0.0525
				cloud_spawn_interval = 20
				cloud_next_spawn = randf_range(cloud_spawn_interval*0.8,cloud_spawn_interval*1.2)
				pattern_spawn_interval = 35
				pattern_next_spawn = randf_range(pattern_spawn_interval*0.8,pattern_spawn_interval*1.2)
				snowman_spawn_interval = 35
				snowman_next_spawn = randf_range(snowman_spawn_interval*0.8,snowman_spawn_interval*1.2)
				wind = 0.125
				difficulty = 8
		8:
			if distance >= 1125: #Blue sky
				wind = 0.25
				cloud_spawn_interval = 25
				cloud_next_spawn = randf_range(cloud_spawn_interval*0.8,cloud_spawn_interval*1.2)
				storm_spawn_interval = 30
				storm_next_spawn = randf_range(storm_spawn_interval*0.8,storm_spawn_interval*1.2)
				possible_patterns = [BuildingTiles.Pattern.THREE_ISLAND,BuildingTiles.Pattern.UP_LEFT_CORNER,BuildingTiles.Pattern.PILLAR,BuildingTiles.Pattern.TPIECE]
				pattern_spawn_interval = 30
				pattern_next_spawn = randf_range(pattern_spawn_interval*0.8,pattern_spawn_interval*1.2)
				difficulty = 9
		9:
			if distance >= 1350:
				camera.raise_speed = 0.05
				cloud_spawn_interval = 30
				cloud_next_spawn = randf_range(cloud_spawn_interval*0.8,cloud_spawn_interval*1.2)
				snowflake_spawn_interval *= 1-(0.045-camera.raise_speed)
				storm_spawn_interval = 25
				storm_next_spawn = randf_range(storm_spawn_interval*0.8,storm_spawn_interval*1.2)
				pattern_spawn_interval = 25
				pattern_next_spawn = randf_range(pattern_spawn_interval*0.8,pattern_spawn_interval*1.2)
				possible_patterns = [BuildingTiles.Pattern.THREE_ISLAND,BuildingTiles.Pattern.UP_LEFT_CORNER,BuildingTiles.Pattern.PILLAR,BuildingTiles.Pattern.TPIECE,BuildingTiles.Pattern.PLUS]
				difficulty = 10
		10:
			if distance >= 1350: #Dark blue sky beginning
				wind = 0.33
				cloud_spawn_interval = 35
				cloud_next_spawn = randf_range(cloud_spawn_interval*0.8,cloud_spawn_interval*1.2)
				storm_spawn_interval = 20
				storm_next_spawn = randf_range(storm_spawn_interval*0.8,storm_spawn_interval*1.2)
				pattern_spawn_interval = 22.5
				pattern_next_spawn = randf_range(pattern_spawn_interval*0.8,pattern_spawn_interval*1.2)
				snowman_spawn_interval = 30
				snowman_next_spawn = randf_range(snowman_spawn_interval*0.8,snowman_spawn_interval*1.2)
				possible_patterns = [BuildingTiles.Pattern.UP_LEFT_CORNER,BuildingTiles.Pattern.PILLAR,BuildingTiles.Pattern.TPIECE,BuildingTiles.Pattern.PLUS,BuildingTiles.Pattern.TRIPLE]
				difficulty = 11
		11:
			if distance >= 1875:
				camera.raise_speed = 0.0475
				snowflake_spawn_interval *= 1-(0.04-camera.raise_speed)
				cloud_spawn_interval = 40
				cloud_next_spawn = randf_range(cloud_spawn_interval*0.8,cloud_spawn_interval*1.2)
				pattern_spawn_interval = 20
				pattern_next_spawn = randf_range(pattern_spawn_interval*0.8,pattern_spawn_interval*1.2)
				possible_patterns = [BuildingTiles.Pattern.UP_LEFT_CORNER,BuildingTiles.Pattern.PILLAR,BuildingTiles.Pattern.TPIECE,BuildingTiles.Pattern.PLUS,BuildingTiles.Pattern.TRIPLE,BuildingTiles.Pattern.ARCH]
				difficulty = 12
		12: 
			if distance >= 2325:
				camera.raise_speed = 0.045
				snowflake_spawn_interval *= 1-(0.035-camera.raise_speed)
				cloud_spawn_interval = 45
				cloud_next_spawn = randf_range(cloud_spawn_interval*0.8,cloud_spawn_interval*1.2)
				storm_spawn_interval = 17.5
				storm_next_spawn = randf_range(storm_spawn_interval*0.8,storm_spawn_interval*1.2)
				pattern_spawn_interval = 15
				pattern_next_spawn = randf_range(pattern_spawn_interval*0.8,pattern_spawn_interval*1.2)
				possible_patterns = [BuildingTiles.Pattern.UP_LEFT_CORNER,BuildingTiles.Pattern.PILLAR,BuildingTiles.Pattern.TPIECE,BuildingTiles.Pattern.PLUS,BuildingTiles.Pattern.TRIPLE,BuildingTiles.Pattern.DIAGANOL]
				difficulty = 13
		13: #Beginning of super dark blue
			if distance >= 2850:
				wind = 0.4
				camera.raise_speed = 0.04
				snowflake_spawn_interval *= 1-(0.03-camera.raise_speed)
				cloud_spawn_interval = 50
				cloud_next_spawn = randf_range(cloud_spawn_interval*0.8,cloud_spawn_interval*1.2)
				storm_spawn_interval = 15
				storm_next_spawn = randf_range(storm_spawn_interval*0.8,storm_spawn_interval*1.2)
				pattern_spawn_interval = 12.5
				pattern_next_spawn = randf_range(pattern_spawn_interval*0.8,pattern_spawn_interval*1.2)
				possible_patterns = [BuildingTiles.Pattern.UP_LEFT_CORNER,BuildingTiles.Pattern.PILLAR,BuildingTiles.Pattern.TPIECE,BuildingTiles.Pattern.PLUS,BuildingTiles.Pattern.TRIPLE,BuildingTiles.Pattern.DIAGANOL,BuildingTiles.Pattern.BUCKET]
				difficulty = 14
		14: # Very dark blue
			if distance >= 3375:
				camera.raise_speed = 0.035
				snowflake_spawn_interval *= 1-(0.025-camera.raise_speed)
				cloud_spawn_interval = 60
				cloud_next_spawn = randf_range(cloud_spawn_interval*0.8,cloud_spawn_interval*1.2)
				storm_spawn_interval = 12
				storm_next_spawn = randf_range(storm_spawn_interval*0.8,storm_spawn_interval*1.2)
				star_spawn_interval = 15
				star_next_spawn = 1
				pattern_spawn_interval = 10
				pattern_next_spawn = randf_range(pattern_spawn_interval*0.8,pattern_spawn_interval*1.2)
				difficulty = 15
		15: #Full space
			if distance >= 4125:
				wind = 0.5
				star_spawn_interval = 10
				star_next_spawn = randf_range(star_spawn_interval*0.8,star_spawn_interval*1.2)
				pattern_spawn_interval = 9
				pattern_next_spawn = randf_range(pattern_spawn_interval*0.8,pattern_spawn_interval*1.2)
				possible_patterns = [BuildingTiles.Pattern.UP_LEFT_CORNER,BuildingTiles.Pattern.PILLAR,BuildingTiles.Pattern.TPIECE,BuildingTiles.Pattern.PLUS,BuildingTiles.Pattern.TRIPLE,BuildingTiles.Pattern.DIAGANOL,BuildingTiles.Pattern.BUCKET,BuildingTiles.Pattern.WALLS]
				difficulty = 16
		16:
			if distance >= 5250:
				wind = 0.75
				camera.raise_speed = 0.03
				snowflake_spawn_interval *= 1-(0.02-camera.raise_speed)
				star_spawn_interval = 8
				star_next_spawn = randf_range(star_spawn_interval*0.8,star_spawn_interval*1.2)
				possible_patterns = [BuildingTiles.Pattern.UP_LEFT_CORNER,BuildingTiles.Pattern.PILLAR,BuildingTiles.Pattern.TPIECE,BuildingTiles.Pattern.PLUS,BuildingTiles.Pattern.TRIPLE,BuildingTiles.Pattern.DIAGANOL,BuildingTiles.Pattern.BUCKET,BuildingTiles.Pattern.WALLS,BuildingTiles.Pattern.LINE]
				difficulty = 17
		17:
			if distance >= 6375:
				wind = 1
				star_spawn_interval = 7
				star_next_spawn = randf_range(star_spawn_interval*0.8,star_spawn_interval*1.2)
				difficulty = 18
		18:
			if distance >= 7500:
				camera.raise_speed = 0.0275
				snowflake_spawn_interval *= 1-(0.015-camera.raise_speed)
				star_spawn_interval = 6
				star_next_spawn = randf_range(star_spawn_interval*0.8,star_spawn_interval*1.2)
				difficulty = 19
		19:
			if distance >= 9000:
				camera.raise_speed = 0.025
				star_spawn_interval = 5
				star_next_spawn = randf_range(star_spawn_interval*0.8,star_spawn_interval*1.2)
				snowflake_spawn_interval *= 1-(0.01-camera.raise_speed)
				difficulty = 20

func restart_game() -> void:
	get_tree().change_scene_to_file("res://Source/Scenes/Main Scenes/Game Scene.tscn")

func return_to_menu() -> void:
	Engine.time_scale = 1
	if is_equal_approx(music.stream.get_length(),MENU_MUSIC_SECONDS):
		(get_parent() as SceneManager).switch_to_menu()
	else:
		get_tree().change_scene_to_file("res://Source/Scenes/Main Scenes/Scene Manager.tscn")

static func save_highscore() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH,FileAccess.WRITE)
	file.store_var(highscore)

static func load_highscore() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file: FileAccess = FileAccess.open(SAVE_PATH,FileAccess.READ)
		highscore = file.get_var(highscore)
	else:
		highscore = 50*15
		save_highscore()

static func save_volume() -> void:
	var file: FileAccess = FileAccess.open(SETTINGS_PATH,FileAccess.WRITE)
	file.store_var(music_volume)
	file.store_var(sfx_volume)

static func load_volume() -> void:
	if FileAccess.file_exists(SETTINGS_PATH):
		var file: FileAccess = FileAccess.open(SETTINGS_PATH,FileAccess.READ)
		music_volume = file.get_var(music_volume)
		sfx_volume = file.get_var(sfx_volume)
	else:
		music_volume = 50
		sfx_volume = 50
		save_volume()
