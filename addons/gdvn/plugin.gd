@tool
extends EditorPlugin

var gdvn_autoload_path: String = "res://addons/gdvn/gdvn.gd"

func _enter_tree():
	add_autoload_singleton("GDVN", gdvn_autoload_path)


func _has_main_screen():
	return false


func _build():
	return true


func _apply_changes():
	pass


func _make_visible(visible):
	pass


func _get_plugin_name():
	return "GDVN"


func _exit_tree():
	remove_autoload_singleton("GDVN")
