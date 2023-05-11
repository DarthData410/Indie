# This file is used to house system wide game needs, like global functions for messages
# etc. 

func msgdialog(text: String, title: String = "Error Title"):
	var dialog = AcceptDialog.new()
	dialog.dialog_text = text
	dialog.title = title
	var scene_tree = Engine.get_main_loop()
	scene_tree.current_scene.add_child(dialog)
	dialog.popup_centered()
	pass


