class_name SceneManager
extends Node

func _process(_delta: float) -> void:
	Game.fullscreen_input_check()

func switch_to_tutorial() -> void:
	$MainMenu.queue_free()
	add_child(load("res://Source/Scenes/Main Scenes/Tutorial Scene.tscn").instantiate())

func switch_to_menu() -> void:
	$Scene.queue_free()
	add_child(preload("res://Source/Scenes/Main Scenes/Main Menu.tscn").instantiate())
