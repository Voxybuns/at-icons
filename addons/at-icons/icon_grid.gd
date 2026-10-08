@tool
extends HFlowContainer

const ICON_PREVIEW_WIDTH: int = 24
const ICON_PREVIEW_HEIGHT: int = 24
const ICON_PREVIEW_CORNER_RADIUS: int = 4
const ICON_SIZE: Vector2 = Vector2(16, 16)

const ICONS_DIRECTORY: String = "res://addons/at-icons/node3d/"

@export_storage var icons : Array[Texture2D]

@export var icon_shader: Shader

@export_tool_button("Update Icon List") var _update_icons := update_icon_list
@export_tool_button("Delete all buttons") var _remove_buttons_tool := _remove_all_children
@export_tool_button("Recreate Buttons") var _init_nodes_tool := _initialize_nodes

var editor_scale: float

var _button_theme: Theme = Theme.new()

var icon_material_light: ShaderMaterial = ShaderMaterial.new()
var icon_material_dark: ShaderMaterial = ShaderMaterial.new()

var icon_scale: float = 1.0

var selected_type: String:
	get:
		return icon_type_button.get_item_text(
			icon_type_button.get_selected_id()
		)

var selected_lang: String:
	get:
		return declaration_type_button.get_item_text(
			declaration_type_button.get_selected_id()
		)
		
var selected_color: Color

@onready var icon_type_button: OptionButton = %TypePickerButton
@onready var declaration_type_button: OptionButton = %DeclarationPickerButton
@onready var scale_toggle: Button = %ScaleToggle
@onready var search_bar: LineEdit = %SearchBar
@onready var json_holder: Node = %JSON

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (ProjectSettings.settings_changed.is_connected(update_icon_type_options)):
		ProjectSettings.settings_changed.disconnect(update_icon_type_options)
	ProjectSettings.settings_changed.connect(update_icon_type_options)
	
	# Make sure the color selector can send a signal to update the previews
	# Icon type -> update colors
	if icon_type_button and icon_type_button.item_selected.is_connected(update_preview_colors):
		icon_type_button.item_selected.disconnect(update_preview_colors)
	icon_type_button.item_selected.connect(update_preview_colors.unbind(1))
	
	# Scale toggle -> update scale
	if scale_toggle and scale_toggle.toggled.is_connected(update_icon_scale):
		scale_toggle.toggled.disconnect(update_icon_scale)
	scale_toggle.toggled.connect(update_icon_scale.unbind(1))
	
	# Icon type -> editor settings
	if icon_type_button and icon_type_button.item_selected.is_connected(_update_editor_settings):
		icon_type_button.item_selected.disconnect(_update_editor_settings)
	icon_type_button.item_selected.connect(_update_editor_settings.unbind(1))
	
	# Declaration type -> editor settings
	if declaration_type_button and declaration_type_button.item_selected.is_connected(_update_editor_settings):
		declaration_type_button.item_selected.disconnect(_update_editor_settings)
	declaration_type_button.item_selected.connect(_update_editor_settings.unbind(1))
	
	# Scale toggle -> editor settings
	if scale_toggle and scale_toggle.toggled.is_connected(_update_editor_settings):
		scale_toggle.toggled.disconnect(_update_editor_settings)
	scale_toggle.toggled.connect(_update_editor_settings.unbind(1))
	
	# Prevent an error from occuring should the picker scene be ran externally
	if Engine.is_editor_hint():
		editor_scale = EditorInterface.get_editor_scale()
	else:
		editor_scale = 1.0
	
	icon_material_light.shader = icon_shader
	icon_material_dark.shader = icon_shader
	
	_remove_all_children()
	for _scale in [1.0, 2.0]:
		icon_scale = _scale
		_initialize_nodes()
	update_icon_scale()
	update_icon_type_options()
	get_editor_theme()
	_update_from_editor_settings.call_deferred()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_THEME_CHANGED:
			if is_node_ready(): # Otherwise it's called in _ready
				get_editor_theme()


func update_icon_scale() -> void:
	match scale_toggle.button_pressed:
		false:
			icon_scale = 1.0
		true:
			icon_scale = 2.0
	
	search(search_bar.text)

func update_preview_colors() -> void:
	selected_color = ProjectSettings.get_setting("@icons/colors/icon_colors", {selected_type: Color.TRANSPARENT})[selected_type] as Color
	match color_mode:
		"dark": 
				icon_material_light.set_shader_parameter("requested_color", selected_color)
				icon_material_dark.set_shader_parameter("requested_color", selected_color)

		"light":
				icon_material_light.set_shader_parameter("requested_color", selected_color.darkened(0.6))
				icon_material_dark.set_shader_parameter("requested_color", selected_color.darkened(0.6))

func update_icon_type_options() -> void:
	icon_type_button.clear()
	for icon_type in ProjectSettings.get_setting("@icons/colors/icon_colors") as Dictionary[String, Color]:
		if icon_type == "Preview":
			continue
		icon_type_button.add_item(icon_type)
	pass

var color_mode := "dark"

func get_editor_theme():
	if not Engine.is_editor_hint():
		return # its already set to dark
	
	var settings := EditorInterface.get_editor_settings()
	match settings.get_setting("interface/theme/icon_and_font_color"):
		0: # Auto
			var col: Color = settings.get_setting("interface/theme/base_color")
			var lightness := col.ok_hsl_l
			color_mode = "light" if lightness > 0.5 else "dark"
		1: # Dark icons ->  light theme
			color_mode = "light"
		2: # Light icons -> dark theme
			color_mode = "dark"
	update_preview_colors()


func _initialize_nodes() -> void:
	#_remove_all_children()
	
	for texture in icons:
		var button: Button = Button.new()
		
		button.custom_minimum_size = Vector2(
			ICON_PREVIEW_WIDTH,
			ICON_PREVIEW_HEIGHT
		) * editor_scale * icon_scale
		button.size = button.custom_minimum_size
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.tooltip_text = texture.resource_path.get_file() + \
				"\nClick to copy this icon's declaration to your clipboard."
		
		var trect_d: TextureRect = TextureRect.new()
		trect_d.texture = texture
		trect_d.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		trect_d.material = icon_material_dark
		trect_d.custom_minimum_size = ICON_SIZE
		trect_d.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		trect_d.size_flags_vertical = Control.SIZE_SHRINK_CENTER

		button.add_child(trect_d)
		trect_d.anchor_bottom = 0.5
		trect_d.offset_bottom = ICON_SIZE.y / 2 * editor_scale * icon_scale
		trect_d.anchor_top = 0.5
		trect_d.offset_top = ICON_SIZE.y / -2 * editor_scale * icon_scale
		trect_d.anchor_right = 0.5
		trect_d.offset_right = ICON_SIZE.x / 2 * editor_scale * icon_scale
		trect_d.anchor_left = 0.5
		trect_d.offset_left = ICON_SIZE.x / -2 * editor_scale * icon_scale
		
		#endregion
		
		button.set_meta("icon", texture.resource_path.get_file().get_basename())
		self.add_child(button)
		button.set_meta("icon_scale", icon_scale)
		
		
		button.pressed.connect(func():
			copy_icon_to_clipboard(
				texture.resource_path.replace(
					"node3d", 
					selected_type.to_lower()
		)))


## Might decrease lag.
func _remove_all_children() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()


func update_icon_list() -> void:
	icons = []
	#region Directory
	var dir = DirAccess.open(ICONS_DIRECTORY)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				file_name = dir.get_next()
				continue
			#else:
			print("Found file: " + file_name)
			if file_name.ends_with(".import"):
				print("Ignoring file " + file_name + " because it is an import file.")
				file_name = dir.get_next()
				continue
			var file := load(dir.get_current_dir() + "/" + file_name)
			if file is not Texture2D:
				push_error("File %s in directory is not a Texture2D resource." % [file_name])
				file_name = dir.get_next()
				continue
			var texture := file as Texture2D
			#endregion
			icons.append(texture)
			file_name = dir.get_next()
	else:
		push_error("An error occurred when trying to access icon path at %s" % [ICONS_DIRECTORY])


## Copies the string to the clipboard.
func copy_icon_to_clipboard(filepath: String) -> void:
	var string: String
	if not FileAccess.file_exists(filepath):
		_create_icon_from_color_pair(filepath)
	match selected_lang:
		"GDScript":
			string = "@icon(\"%s\")\n" % [filepath]
		"C#":
			string = "[GlobalClass, Icon(\"%s\")]\n" % [filepath]
	
	DisplayServer.clipboard_set(string)
	EditorInterface.get_editor_toaster().push_toast("Icon declaration copied to clipboard!")


func search(text: String) -> void:
	if not text: # No query:
		for child in get_children():
			child.visible = child.get_meta("icon_scale") == icon_scale
		return
	
	text = text.replace(" ", "_")
	
	var search_aliases: Dictionary[String, Array] = json_holder.search_aliases
	# There is a query
	for child in get_children():
		child.visible = false
		if child.get_meta("icon_scale") != icon_scale:
			continue # It's hidden already
		
		var icon_aliases: Array
		if child.get_meta("icon") not in search_aliases:
			icon_aliases = [child.get_meta("icon")]
		else:
			icon_aliases = search_aliases[child.get_meta("icon")]
		for alias: String in icon_aliases:
			if text in alias:
				child.show()
				break # if one alias has it, don't bother with the others


func _get_items(option_button: OptionButton, exclude_first := true) -> Array[String]:
	var array: Array[String]
	for i in range(option_button.item_count):
		if i == 0: continue
		array.append(option_button.get_item_text(i))
	return array


const SETTING_NAME_COLOR := "@icons/icon_color"
const SETTING_NAME_LANG := "@icons/declaration_language"
const SETTING_NAME_SCALE := "@icons/double_scale"


func _update_editor_settings() -> void:
	var settings := EditorInterface.get_editor_settings()
	
	settings.set_setting(SETTING_NAME_COLOR, selected_type)
	settings.set_setting(SETTING_NAME_LANG, selected_lang)
	settings.set_setting(SETTING_NAME_SCALE, scale_toggle.button_pressed)
	
	#region setting info dicts
	var setting_color := {
		name = SETTING_NAME_COLOR,
		type = TYPE_STRING,
		hint = PROPERTY_HINT_ENUM,
		hint_string = _get_items(icon_type_button).reduce((func(accum, next):
			return accum + "," + next), icon_type_button.get_item_text(0)
		)
	}
	
	var setting_lang := {
		name = SETTING_NAME_LANG,
		type = TYPE_STRING,
		hint = PROPERTY_HINT_ENUM,
		hint_string = _get_items(declaration_type_button).reduce((func(accum, next):
			return accum + "," + next), declaration_type_button.get_item_text(0)
		)
	}
	
	var setting_double_scale := {
		name = SETTING_NAME_SCALE,
		type = TYPE_BOOL,
		hint = PROPERTY_HINT_NONE,
		hint_string = ""
	}
	#endregion
	
	settings.add_property_info(setting_color)
	settings.add_property_info(setting_lang)
	settings.add_property_info(setting_double_scale)


func _update_from_editor_settings() -> void:
	var settings := EditorInterface.get_editor_settings()
	
	if settings.has_setting(SETTING_NAME_COLOR):
		icon_type_button.select(_get_items(icon_type_button, false).find(
			settings.get_setting(SETTING_NAME_COLOR)
		) + 1)
	if settings.has_setting(SETTING_NAME_LANG):
		declaration_type_button.select(_get_items(declaration_type_button, false).find(
			settings.get_setting(SETTING_NAME_LANG)
		) + 1)
	if settings.has_setting(SETTING_NAME_SCALE):
		scale_toggle.button_pressed = settings.get_setting(SETTING_NAME_SCALE)
	
	update_preview_colors()
	_update_editor_settings() # If there's no settings, add them. Otherwise nothing changes.

func _create_icon_from_color_pair(filepath: String) -> void:
	if not (DirAccess.dir_exists_absolute(filepath.get_base_dir())):
		DirAccess.make_dir_absolute(filepath.get_base_dir())
	var baseIconPath = filepath.replace(selected_type.to_lower(), "node3d")
	var iconString = FileAccess.get_file_as_string(baseIconPath)
	var fillRegex = RegEx.new()
	fillRegex.compile('fill="([^"]*)"')
	var newIcon = fillRegex.sub(iconString, 'fill="#%s"' % selected_color.to_html(false), true)
	var newIconFile = FileAccess.open(filepath, FileAccess.WRITE)
	newIconFile.store_string(newIcon)
	newIconFile.close()
	
