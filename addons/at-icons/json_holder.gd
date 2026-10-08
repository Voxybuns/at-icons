@tool
extends Node

## Here, you should put the [code]icons.json[/code] file contents, found at 
## [code]at-icons/site_src/_data/icons.json[/code] in the raw repo.
## If that file is updated, update it here too. 
@export_multiline() var json_string : String

## The cached search aliases. Use [code]update_search_aliases()[/code] to update them
@onready var search_aliases: Dictionary[String, Array]

func _get_raw_data() -> Dictionary:
	return JSON.parse_string(json_string)


func _csv_to_array(csv: String) -> PackedStringArray:
	return csv.split(", ")


## Turns icon data into a Dictionary[filename: String, aliases: Array[String]] format.
## The aliases include the original file name.
func _get_search_aliases(data := _get_raw_data()) -> Dictionary[String, Array]:
	var aliases: Dictionary[String, Array] = {}
	for icon: String in data:
		aliases[icon] = _csv_to_array(data[icon].description)
		aliases[icon].append(icon)
	
	return aliases

func update_search_aliases() -> void:
	search_aliases = _get_search_aliases()


func _ready() -> void:
	update_search_aliases()
