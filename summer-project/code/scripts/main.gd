extends Node3D
@onready var record_holder = $Shelf/Node3D

#load music into individual records (currently has errors due to only 1 album being present)
func _ready() -> void:
	setup_display_albums()


func setup_display_albums():
	await MusicManager.initialize_display_records()
	var i : int = 0
	for record : Record in record_holder.get_children():
		if(!record.name.contains("Display")):
			continue
		MusicManager.load_record_data(record, MusicManager.all_albums[i])
		i+=1
