extends Node
var all_albums : Array[Album] = []
var music_directory : String = "res://assets/music/"
var request_creator : SpotifyRequests = SpotifyRequests.new()

var CURRENT_IN_USE_RECORD : Record

##initialize display records with set choices to show user how to play music
##TODO be changed at runtime by user
func initialize_display_records():
	add_child(request_creator)
	await request_creator.start_auth()
	
	var album_ids : Array = [
		"2W6MaUiInBkna5DfBES4E3", #badmotorfinger by soundgarden
		"49R4Qye4UUwzjPPQhtCkRe", #alice in chains self titled
		"0YW9Qke0AfzNVISsPQ7KoF", #dust by screaming trees
		"5l5m1hnH4punS1GQXgEi3T", #lateralus by tool
		"63HdXCn0Xz1pRZc2GzMw7k", #temple of the dog self titled
		"2NU3mpjBFtZPUYjjT9pJoq" #welcome to sky valley by kyuss
	]
	
	for id : String in album_ids:
		all_albums.append(await create_album(id))

##helper method to construct an album from an spotify id
func create_album(album_id : String) -> Album:
		var album_dict : Dictionary = await request_creator.create_api_request(HTTPClient.METHOD_GET,"/albums/" + album_id);
		var track_list : Array = album_dict["tracks"]["items"]
		var album_cover : Image= await request_creator.get_image(album_dict["images"][0]["url"])
		var album : Album = Album.new( album_cover, album_dict,track_list)
		return album

##handles the api request for searching for an album
func search_request(query : String) -> Array:
	var album_dict : Dictionary = await request_creator.create_api_request(HTTPClient.METHOD_GET,"search?q=" + query.uri_encode() + "&type=album&limit=3")
	var album_array = album_dict["albums"]["items"]
	return album_array

##handles api request for playing the first song of an album and queuing the rest
func play_album(tracks : Array):
	if(tracks == null):
		return
	request_creator.create_api_request(HTTPClient.METHOD_PUT, "me/player/play", JSON.stringify({"uris": [tracks[0]["uri"]]}))
	var i = 1
	while i < tracks.size():
		await request_creator.create_api_request(HTTPClient.METHOD_POST, "me/player/queue?uri=" + tracks[i]["uri"].uri_encode(), "{}")
		i+=1

func switch_album(album : Album):
	if(!Global.record_in_use || CURRENT_IN_USE_RECORD == null):
		return
	CURRENT_IN_USE_RECORD.album = album
	load_record_data(CURRENT_IN_USE_RECORD, album)


func load_record_data(record : Record, album : Album):
	record.album = album
	record.disk.music = record.album.track_list
	
	#setup album image using image plane
	var album_cover : Image = album.album_cover
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


#class for holding music information
class Album:
	var album_cover : Image
	var info : Dictionary
	var track_list : Array
	func _init(cover : Image, inf: Dictionary, tracks : Array) -> void:
		album_cover = cover
		info = inf
		track_list = tracks
