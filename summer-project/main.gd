extends Node3D
var all_records = []
var all_albums = MusicManager.get_albums()
@onready var record_holder = $Shelf/Node3D

func _ready() -> void:
	var i = 0
	for child in record_holder.get_children(false):
		child.disk = RecordDisk.new(all_albums[i])
		all_records.append(child)
		
