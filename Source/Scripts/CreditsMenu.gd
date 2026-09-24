class_name CreditsScreen
extends Node2D

@onready var credits_label: Label = $ScrollContainer/VBoxContainer/CreditsText
@onready var first_party_label: Label = $ScrollContainer/VBoxContainer/FirstPartyText
@onready var godot_label: Label = $ScrollContainer/VBoxContainer/GodotText
@onready var third_party_label: Label = $ScrollContainer/VBoxContainer/ThirdPartyText
@onready var attribution_party_label: Label = $ScrollContainer/VBoxContainer/AttributionText
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var license_button: Button = $LicenseButton
static var credits_string: String = _load_credits_text()
static var first_credits_string: String = _get_first_licenses_string()
static var godot_credits_string: String = _get_godot_licenses_string()
static var third_credits_string: String = _get_third_licenses_string()
static var attribution_credits_string: String = _get_attribution_string()

func _ready() -> void:
	credits_label.text = credits_string
	godot_label.text = godot_credits_string
	attribution_party_label.text = attribution_credits_string
	
func update_credits() -> void:
	scroll_container.scroll_vertical = 0
	license_button.text = "Open-Source Notices"
	credits_label.visible = true
	first_party_label.visible = false
	godot_label.visible = false
	attribution_party_label.visible = false
	third_party_label.visible = false
		
func show_licenses() -> void:
	scroll_container.scroll_vertical = 0
	if credits_label.visible:
		license_button.text = "Return to Credits"
		credits_label.visible = false
		first_party_label.visible = true
		godot_label.visible = true
		attribution_party_label.visible = true
		third_party_label.visible = true
		if(first_party_label.text == ""):
			first_party_label.text = first_credits_string
			godot_label.text = godot_credits_string
			attribution_party_label.text = attribution_credits_string
			third_party_label.text = third_credits_string
	else:
		update_credits()

static func _load_credits_text() -> String:
	var the_credits_string: String = "Open-Source at\ngithub.com/JigglyJelo/Antarctic-Ascent\n\n"
	var version: Dictionary = Engine.get_version_info()
	the_credits_string += "Game made in Godot %d.%d" % [version.major, version.minor] + (".%d" % version.patch if version.patch != 0 else "") + "\n"
	the_credits_string += "\nCode available under GPL 3.0-or-later\n\n"
	the_credits_string += "Sprites & Images by JigglyJello available under CC BY-SA 4.0\ncreativecommons.org/licenses/by-sa/4.0/\n\n"
	the_credits_string += FileAccess.get_file_as_string("res://Assets/Audio/Music/Music Credits.txt") + "\n\n"
	the_credits_string += FileAccess.get_file_as_string("res://Assets/Audio/SFX/SFX Credits.txt") + "\n\n"
	the_credits_string += "Press Start 2P font licensed under OFL 1.1"
	return the_credits_string
	
static func _get_first_licenses_string() -> String:
	var full_text: String = FileAccess.get_file_as_string("res://LICENSE")
	full_text += "\n\n" + FileAccess.get_file_as_string("res://Assets/OFL.txt")
	return full_text
	
static func _get_godot_licenses_string() -> String:
	var full_text: String = ""
	
	full_text += "========================================\n"
	full_text += "GODOT ENGINE LICENSE\n"
	full_text += "========================================\n\n"
	full_text += Engine.get_license_text() + "\n\n\n"
	return full_text

static func _get_third_licenses_string() -> String:
	var full_text: String = ""
	full_text += "========================================\n"
	full_text += "THIRD-PARTY LICENSES\n"
	full_text += "========================================\n\n"
	
	var licenses: Dictionary = Engine.get_license_info()
	for license_name in licenses.keys():
		full_text += "--- " + license_name + " ---\n"
		full_text += str(licenses[license_name]) + "\n\n"
	return full_text

static func _get_attribution_string() -> String:
	var full_text: String = ""
	full_text += "========================================\n"
	full_text += "COPYRIGHT ATTRIBUTIONS\n"
	full_text += "========================================\n\n"
	
	var copyrights: Array = Engine.get_copyright_info()
	for component in copyrights:
		full_text += "Component: " + str(component["name"]) + "\n"
		
		for part in component["parts"]:
			full_text += "  License: " + str(part["license"]) + "\n"
			full_text += "  Copyright Holders: \n"
			
			for cp in part["copyright"]:
				full_text += "    - " + str(cp) + "\n"
				
		full_text += "----------------------------------------\n"
		
	return full_text
