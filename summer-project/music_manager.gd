extends Node
var all_albums : Array[Album]
func get_albums() -> Array[Album]:
	var folders = DirAccess.get_directories_at("res://music/")
	
	for folder in folders:
		var files = DirAccess.get_files_at("res://music/" + folder)
		var temp_list : Array[AudioStreamMP3] = [] 
		for file in files:
			var song_filepath = "res://music/" + folder + file
			if(song_filepath.contains("import")):
				continue
			var song = load("res://music/" + folder +"/" +file)
			temp_list.append(song)
		all_albums.append(Album.new(temp_list))
	return all_albums

class Album:
	var songs : Array[AudioStreamMP3]
	func _init(all_songs : Array[AudioStreamMP3]) -> void:
		songs = all_songs
