@tool
extends EditorPlugin

var dock : EditorDock

var COLOR_SETTING: Dictionary = {
		"name": "@icons/colors/icon_colors",
		"value": DEFAULT_COLORS,
		"type": TYPE_DICTIONARY,
		"hint": PROPERTY_HINT_DICTIONARY_TYPE,
		"hint_string": "%d:;%d:" % [TYPE_STRING, TYPE_COLOR]
	}

const DEFAULT_COLORS: Dictionary[String, Color] = {
	"Preview": Color("292929"),
	"Node": Color("e0e0e0"),
	"Node2D": Color("8da5f3"),
	"Node3D": Color("fc7f7f"),
	"Control": Color("8eef97"),
	"Animation": Color("c38ef1"),
	"Mesh": Color("ffca5f"),
}

#static var DEFAULT_COLORS: Dictionary[String, Color] = {
#	"Preview": AtIconsColorPair.new(Color("292929"), Color("e5e5e5")),
#	"Node": AtIconsColorPair.new(Color("e0e0e0"), Color("5a5a5a")),
#	"Node2D": AtIconsColorPair.new(Color("8da5f3"), Color("3d64dd")),
#	"Node3D": AtIconsColorPair.new(Color("fc7f7f"), Color("cd3838")),
#	"Control": AtIconsColorPair.new(Color("8eef97"), Color("2fa139")),
#	"Animation": AtIconsColorPair.new(Color("c38ef1"), Color("a85de9")),
#	"Mesh": AtIconsColorPair.new(Color("ffca5f"), Color("fea900")),
#}

#func _enable_plugin() -> void:
	## Add autoloads here.
	#pass


#func _disable_plugin() -> void:
	## Remove autoloads here.
	#pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	_add_settings()
	dock = EditorDock.new()
	dock.title = "@icons"
	dock.dock_icon = preload("res://addons/at-icons/node/at.svg")
	dock.default_slot = EditorDock.DOCK_SLOT_RIGHT_UL
	var dock_content := preload("res://addons/at-icons/icon_browser.tscn").instantiate()
	dock.add_child(dock_content)
	add_dock(dock)
	
func _add_settings() -> void:
	if ProjectSettings.has_setting(COLOR_SETTING.name):
		return
	ProjectSettings.set_setting(COLOR_SETTING.name, COLOR_SETTING.value)
	ProjectSettings.set_initial_value(COLOR_SETTING.name, COLOR_SETTING.value)
	ProjectSettings.add_property_info(COLOR_SETTING)
	
func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_dock(dock)
	dock.queue_free()
	dock = null
