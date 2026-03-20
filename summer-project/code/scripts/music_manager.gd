extends Node
var all_albums : Array[Album]
var music_directory : String = "res://assets/music/"

#TODO switch to spotify API implementation 
func get_albums() -> Array[Album]:
	var folders = DirAccess.get_directories_at(music_directory)
	
	#create AudioStreamMP3 objects using music files and store them into array
	for folder in folders:
		var files = DirAccess.get_files_at(music_directory + folder)
		var temp_list : Array[AudioStreamMP3] = [] 
		for file in files:
			var song_filepath = music_directory + folder + file
			if(song_filepath.contains("import")):
				continue
			var song = load(music_directory + folder +"/" +file)      #create MP3 Object
			temp_list.append(song)
		all_albums.append(Album.new(temp_list))
	return all_albums

#class for holding music information
#TODO add album image and metadata
class Album:
	var songs : Array[AudioStreamPlayer]
	func _init(all_songs : Array[AudioStreamMP3]) -> void:
		for song in all_songs:
			var player :AudioStreamPlayer = AudioStreamPlayer.new()
			player.volume_db = 0.5
			player.stream = load(song.resource_path)
			songs.append(player)
