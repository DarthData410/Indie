extends CanvasLayer

@onready var main = $Main
@onready var settings = $Settings

func _on_button_play_pressed():
	get_tree().change_scene_to_file("res://scenes/maingame.tscn")

func _on_button_settings_pressed():
	main.visible = false
	settings.visible = true

func _on_button_quit_pressed():
	get_tree().quit()

func _on_button_settings_back_pressed():
	main.visible = true
	settings.visible = false
