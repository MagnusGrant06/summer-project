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
		record.album = MusicManager.all_albums[i]
		record.disk.music = record.album.track_list
		
		#setup album image using image plane
		var album_cover : Image = MusicManager.all_albums[i].album_cover
		var material : StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_texture = ImageTexture.create_from_image(album_cover)
		record.image_plane.material_override = material
		
		#sample random parts of album cover to get roughly average color
		album_cover.convert(Image.FORMAT_RGBA8)
		var rand : RandomNumberGenerator = RandomNumberGenerator.new()
		var accumulated_col = Vector3(0,0,0)
		for pix in range(10):
			var rand_col = rand.randi_range(0,album_cover.get_width())
			var rand_row = rand.randi_range(0,album_cover.get_height())
			var col : Color = album_cover.get_pixel(rand_col, rand_row)
			accumulated_col += Vector3(col.r,col.g,col.b)
		
		#change rest of record to average color
		accumulated_col /= 10
		var back_material : StandardMaterial3D = StandardMaterial3D.new()
		back_material.albedo_color = Color(accumulated_col.x, accumulated_col.y, accumulated_col.z)
		record.case.material_override = back_material
		i+=1
