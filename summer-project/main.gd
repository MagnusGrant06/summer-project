extends Node3D
var all_records = []
@onready var shelf = $Shelf

func _ready() -> void:
	for child in shelf.get_children(false):
		all_records.append(child)
