class_name MainMenu
extends Node
var menu_nodes: Node2D
var credits_screen: Node2D

func _ready() -> void:
	Game.load_highscore()
	@warning_ignore("integer_division")
	$MenuNodes/HiscoreLabel.text = "Highscore: " + str(int(Game.highscore/15)) + "M"
	Game.load_volume()
	set_music_volume(Game.music_volume)
	set_sfx_volume(Game.sfx_volume)
	menu_nodes = $MenuNodes
	credits_screen = $CreditsScreen
	$MenuNodes/MusicSlider.value = Game.music_volume
	$MenuNodes/SFXSlider.value = Game.sfx_volume

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func start_game() -> void:
	get_tree().change_scene_to_file("res://Source/Scenes/Main Scenes/Game Scene.tscn")

func start_tutorial() -> void:
	(get_parent() as SceneManager).switch_to_tutorial()

func set_music_volume(volume: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(volume/100))
	Game.music_volume = volume
	Game.save_volume()

func set_sfx_volume(volume: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(volume/100))
	Game.sfx_volume = volume
	Game.save_volume()

func show_credits() -> void:
	credits_screen.global_position.x = 0
	menu_nodes.global_position.x = 720

func show_menu() -> void:
	credits_screen.global_position.x = 720
	menu_nodes.global_position.x = 0
