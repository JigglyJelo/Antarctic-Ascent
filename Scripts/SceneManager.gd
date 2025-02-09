class_name SceneManager
extends Node

func switch_to_tutorial() -> void:
	$MainMenu.queue_free()
	add_child(load("res://Tutorial Scene.tscn").instantiate())
func switch_to_menu() -> void:
	$Scene.queue_free()
	add_child(preload("res://Main Menu.tscn").instantiate())
