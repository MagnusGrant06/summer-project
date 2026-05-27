extends Node
var all_albums : Array[Album]
var music_directory : String = "res://assets/music/"

func test_request():
	var request : SpotifyRequests = SpotifyRequests.new()
	add_child(request)
	await request.start_auth()
	print(await request.create_api_request(HTTPClient.METHOD_PUT, "me/player/play", JSON.stringify({"uris": ["spotify:track:0W7AbEauB7cP4pidLclApe"]})))

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
