extends Node3D
@onready var record_holder = $Shelf/Node3D

#load music into individual records (currently has errors due to only 1 album being present)
func _ready() -> void:
	await MusicManager.initialize_display_records()
	var i : int = 0
	for record : Record in record_holder.get_children():
		if(!record.name.contains("Display")):
			continue
		record.album = MusicManager.all_albums[i]
		var album_cover : ImageTexture = ImageTexture.create_from_image(MusicManager.all_albums[i].album_cover)
		var material : StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_texture = album_cover
		record.image_plane.material_override = material
		i+=1
