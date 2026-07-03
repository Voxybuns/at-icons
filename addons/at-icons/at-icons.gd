@tool
extends EditorPlugin

const PATH := "res://addons/at-icons/at_icons_browser.scn"
const MENU_ITEM := "Open @icons picker scene"
var dock : EditorDock

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
	dock = EditorDock.new()
	dock.dock_icon = preload("res://addons/at-icons/node/at.svg")
	dock.default_slot = EditorDock.DOCK_SLOT_RIGHT_UL
	var dock_content := preload("res://addons/at-icons/icon_browser.tscn").instantiate()
	dock.add_child(dock_content)
	add_dock(dock)

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_tool_menu_item(MENU_ITEM)
	remove_dock(dock)
	dock.queue_free()
	dock = null


func open_picker() -> void:
	EditorInterface.play_custom_scene(PATH)
