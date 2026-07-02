@tool
extends EditorPlugin

const PATH := "res://addons/at-icons/at_icons_browser.scn"
const MENU_ITEM := "Open @icons picker scene"


#func _enable_plugin() -> void:
	## Add autoloads here.
	#pass
#
#
#func _disable_plugin() -> void:
	## Remove autoloads here.
	#pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_tool_menu_item(MENU_ITEM, open_picker)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_tool_menu_item(MENU_ITEM)


func open_picker() -> void:
	EditorInterface.play_custom_scene(PATH)
