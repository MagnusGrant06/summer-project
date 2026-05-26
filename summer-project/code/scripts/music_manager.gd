extends Node
var all_albums : Array[Album]
var music_directory : String = "res://assets/music/"

const CLIENT_ID : String = "f51c4317a5ad4491b34d088f8c746326"
const CLIENT_SECRET : String = "5990893fbc2c464d94d7601b51779126"

var access_token : String = ""
var search_results : Array = []
#LEGACY IMPLEMENTATION PRE API INTEGRATION
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


## Initialize users credentials with spotify API to allow for http requests
func initialize_user_token():
	var http_request : HTTPRequest = HTTPRequest.new();
	add_child(http_request);
	http_request.request_completed.connect(_on_token_received)
	
	var credentials : String = CLIENT_ID + ":" + CLIENT_SECRET
	var encoded_credentials : String = Marshalls.utf8_to_base64(credentials)
	
	var headers : Array[String ]= [
		"Authorization: Basic " + encoded_credentials,
		"Content-Type: application/x-www-form-urlencoded"
	]
	
	var error : Error = http_request.request(
		"https://accounts.spotify.com/api/token",
		headers,
		HTTPClient.METHOD_POST,
		"grant_type=client_credentials"
	);
	if(error != OK):
		push_error("Token request failed")
		

##helper method to intialize user credentials
func _on_token_received(result, response_code, _headers, body):
	if(result != HTTPRequest.RESULT_SUCCESS):
		push_error("Token request failed")
	if(response_code != 200):
		push_error("Spotify rejected token request, code: " + str(response_code))
		return
	
	var data = JSON.parse_string(body.get_string_from_utf8())
	access_token = data["access_token"]

## Search spotify database with user query and fill array of dictionaries
##containing search results
func search_albums(query : String):
	var http_request : HTTPRequest = HTTPRequest.new();
	add_child(http_request);
	http_request.request_completed.connect(_on_search_received)
	var headers = [
		"Authorization: Bearer " + access_token
	]
	
	var error : Error = http_request.request(
		"https://api.spotify.com/v1/search?q=" + query.uri_encode() + "&type=album&limit=2",
		headers
	)
	
	if(error != OK):
		push_error("Search failure")

##helper method to get search results from spotify
func _on_search_received(result, response_code, _headers, body):
	if(result != HTTPRequest.RESULT_SUCCESS):
		push_error("Search request failed")
	if(response_code != 200):
		push_error("Spotify rejected search request, code: " + str(response_code))
		return
	
	var data = JSON.parse_string(body.get_string_from_utf8())
	var albums : Array = data["albums"]["items"]
	search_results.clear()
	for album in albums:
		search_results.append({
			"name": album["name"],
			"uri": album["uri"],
			"artist": album["artists"][0]["name"],
			"cover_url": album["images"][0]["url"]
		})
		
	draw_album_cover(search_results[0]["cover_url"])


##draws image using spotify API image stored in dictionary for that album
func draw_album_cover(img_url : String):
	var http_request : HTTPRequest = HTTPRequest.new();
	add_child(http_request);
	http_request.request_completed.connect(_image_request_completed)
	
	var error : Error = http_request.request(img_url)
	
	if(error != OK):
		push_error("Search failure")

##helper method to draw images using http requests
func _image_request_completed(result, _response_code, _headers, body):
	if(result != HTTPRequest.RESULT_SUCCESS):
		push_error("Image couldnt be downloaded, try another image")
		
	var image :Image = Image.new()
	var error : Error = image.load_jpg_from_buffer(body)
	if(error != OK):
		push_error("couldnt load image")
		
	var texture : Texture = ImageTexture.create_from_image(image)
	
	var texture_rect : TextureRect = TextureRect.new()
	add_child(texture_rect)
	texture_rect.texture = texture


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
