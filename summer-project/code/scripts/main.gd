extends Node3D
@onready var record_holder = $Shelf/Node3D

#load music into individual records (currently has errors due to only 1 album being present)
func _ready() -> void:
	MusicManager.test_request()
