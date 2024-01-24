@tool
extends EditorPlugin

var gdvn_autoload_path: String = "res://addons/gdvn/gdvn.gd"

var gdvn_singleton: GDVN

func _enter_tree():
	gdvn_singleton = GDVN.new()
	Engine.register_singleton("GDVN", gdvn_singleton)


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
	Engine.unregister_singleton("GDVN")
