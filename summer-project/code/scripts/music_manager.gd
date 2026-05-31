extends Node
var all_albums : Array[Album] = []
var music_directory : String = "res://assets/music/"

##initialize display records with set choices to show user how to play music
##TODO be changed at runtime by user
func initialize_display_records():
	var request : SpotifyRequests = SpotifyRequests.new()
	add_child(request)
	await request.start_auth()
	
	var album_ids : Array = [
		"2W6MaUiInBkna5DfBES4E3", #badmotorfinger by soundgarden
		"49R4Qye4UUwzjPPQhtCkRe", #alice in chains self titled
		"0YW9Qke0AfzNVISsPQ7KoF", #dust by screaming trees
		"5l5m1hnH4punS1GQXgEi3T", #lateralus by tool
		"63HdXCn0Xz1pRZc2GzMw7k", #temple of the dog self titled
		"2NU3mpjBFtZPUYjjT9pJoq" #welcome to sky valley by kyuss
	]
	
	for id : String in album_ids:
		var album_dict : Dictionary = await request.create_api_request(HTTPClient.METHOD_GET,"/albums/" + id);
		var track_list : Array = album_dict["tracks"]["items"]
		var album_cover : Image = await request.get_image(album_dict["images"][0]["url"])
		all_albums.append(Album.new( album_cover, album_dict,track_list))
	

#class for holding music information
class Album:
	var album_cover : Image
	var info : Dictionary
	var track_list : Array
	func _init(cover : Image, inf: Dictionary, tracks : Array) -> void:
		album_cover = cover
		info = inf
		track_list = tracks
