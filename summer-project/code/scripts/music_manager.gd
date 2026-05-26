extends Node
var all_albums : Array[Album]
var music_directory : String = "res://assets/music/"

const CLIENT_ID : String = "f51c4317a5ad4491b34d088f8c746326"
const CLIENT_SECRET : String = "5990893fbc2c464d94d7601b51779126"
const REDIRECT_URI : String = "http://127.0.0.1:8888/callback"
const SCOPES: String = "user-modify-playback-state user-read-playback-state"

var _code_verifier : String = ""
var _server : TCPServer = TCPServer.new()

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


#func _process(_delta: float) -> void:
	#if(_server.is_listening() && _server.is_connection_available()):
		#var peer : StreamPeerTCP = _server.take_connection()
		#await get_tree().create_timer(10.0).timeout
		#var request : String = peer.get_utf8_string(2048)
		#
		#var response: String = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n" + \
			#"<html><body>Logged in! You can close this tab.</body></html>"
		#peer.put_data(response.to_utf8_buffer())
		#
		#_server.stop()
		#print("Caught redirect:")
		#print(request)

func _poll_for_connection():
	print("Starting poll loop")
	while not _server.is_connection_available():
		await get_tree().create_timer(0.1).timeout
	
	print("Connection available!")
	
	var peer : StreamPeerTCP = _server.take_connection()
	
	print("Peer status: " + str(peer.get_status()))
	
	await get_tree().create_timer(1.0).timeout
	var request : String = ""
	var attempts : int = 0
	while request == "" and attempts < 20:
		var bytes: int = peer.get_available_bytes()
		if(bytes > 0):
			var data : Array = peer.get_data(bytes)
			request = data[1].get_string_from_ascii()
		await get_tree().create_timer(0.1).timeout
		attempts +=1
	
	
	var response: String = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n" + \
         "<html><body>Logged in! You can close this tab.</body></html>"
	peer.put_data(response.to_utf8_buffer())
	
	_server.stop()
	print("Caught redirect:")
	print(request)
	


## Initialize users credentials with spotify API to allow for http requests
func start_auth():
	_code_verifier = generate_code_verifier()
	var challenge : String = generate_code_challenge(_code_verifier)
	
	var url : String = "https://accounts.spotify.com/authorize" + \
		"?client_id=" + CLIENT_ID + \
		"&response_type=code" + \
		"&redirect_uri=" + REDIRECT_URI.uri_encode() + \
		"&scope=" + SCOPES.uri_encode() + \
		"&code_challenge_method=S256" + \
		"&code_challenge=" + challenge
	
	OS.shell_open(url)
	_server.listen(8888)
	print("browser opened listning")
	_poll_for_connection()

###helper method to intialize user credentials
#func _on_token_received(result, response_code, _headers, body):
	#if(result != HTTPRequest.RESULT_SUCCESS):
		#push_error("Token request failed")
	#if(response_code != 200):
		#push_error("Spotify rejected token request, code: " + str(response_code))
		#return
	#
	#var data = JSON.parse_string(body.get_string_from_utf8())
	#access_token = data["access_token"]

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

func generate_code_verifier() -> String:
	var chars : String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	var verifier : String = ""
	for i in range(64):
		verifier += chars[randi() % chars.length()]
	return verifier

func generate_code_challenge(verifier: String) -> String:
	var ctx: HashingContext = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(verifier.to_utf8_buffer())
	var hash : PackedByteArray = ctx.finish()
	
	return Marshalls.raw_to_base64(hash) \
	 .replace("+", "-").replace("/","_").replace("=","")
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
