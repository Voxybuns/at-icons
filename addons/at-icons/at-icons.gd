@tool
extends EditorPlugin

var dock : EditorDock

#func _enable_plugin() -> void:
	## Add autoloads here.
	#pass


#func _disable_plugin() -> void:
	## Remove autoloads here.
	#pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	dock = EditorDock.new()
	dock.dock_icon = preload("res://addons/at-icons/node/at.svg")
	dock.default_slot = EditorDock.DOCK_SLOT_RIGHT_UL
	var dock_content := preload("res://addons/at-icons/icon_browser.tscn").instantiate()
	dock.add_child(dock_content)
	add_dock(dock)

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_dock(dock)
	dock.queue_free()
	dock = null
