class_name SpotifyRequests extends Node

const CLIENT_ID : String = "f51c4317a5ad4491b34d088f8c746326"
const CLIENT_SECRET : String = "5990893fbc2c464d94d7601b51779126"
const REDIRECT_URI : String = "http://127.0.0.1:8888/callback"
const SCOPES: String = "user-modify-playback-state user-read-playback-state"

var _code_verifier : String = ""
var _server : TCPServer = TCPServer.new()

var access_token : String = ""
var search_results : Array = []

#func _init():
	#auth_completed.connect(_on_token_exchanged)

## Initialize users credentials with spotify API to allow for http requests
func start_auth():
	access_token = ""
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
	await _poll_for_connection()
	

##check for connections until one is found, then connect user to spotify
func _poll_for_connection():
	while not _server.is_connection_available():
		await get_tree().create_timer(0.1).timeout
	
	var peer : StreamPeerTCP = _server.take_connection()
	
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
	var code :String = extract_user_code(request)
	print(code)
	await exchange_code_for_token(code)

##helper method to extract user credentials from http request
func extract_user_code(request : String) -> String:
	var first_line : String = request.split("\n")[0]
	var after_code : String = first_line.split("code=")[1]
	var code: String = after_code.split(" ")[0]
	
	return code
	
##get access code for the users token to use in http requests
func exchange_code_for_token(code : String):
	var http_request : HTTPRequest = HTTPRequest.new()
	add_child(http_request)
	var headers : Array = ["Content-Type: application/x-www-form-urlencoded"]
	
	var body: String = "grant_type=authorization_code" + \
		"&code=" + code + \
		"&redirect_uri=" + REDIRECT_URI.uri_encode() + \
		"&client_id=" + CLIENT_ID + \
		"&code_verifier=" + _code_verifier
	
	var error : Error = http_request.request(
		"https://accounts.spotify.com/api/token",
		headers,
		HTTPClient.METHOD_POST,
		body
	)
	
	var request : Array = await http_request.request_completed
	
	if(error != OK):
		push_error("token exchange request failed")
	
	if(request[0] != HTTPRequest.RESULT_SUCCESS):
		push_error("Token exchange failed")
		return
	
	if(request[1] != 200):
		push_error("Response code: " + str(request[0]))
		push_error(request[3].get_string_from_utf8())
		return;
	
	var data : Dictionary = JSON.parse_string(request[3].get_string_from_utf8())
	access_token = data["access_token"]
	print("Access token: " + access_token)
	
	

func _on_token_exchanged(result, response_code, _headers, body):
	if(result != HTTPRequest.RESULT_SUCCESS):
		push_error("Token exchange failed")
		return
	
	if(response_code != 200):
		push_error("Response code: " + str(response_code))
		push_error(body.get_string_from_utf8())
		return;
	
	var data : Dictionary = JSON.parse_string(body.get_string_from_utf8())
	access_token = data["access_token"]
	print("Access token: " + access_token)


func create_api_request(request_type : HTTPClient.Method, uri : String, body : String = "" ):
	var http_request : HTTPRequest = HTTPRequest.new()
	add_child(http_request)
	
	var headers: Array = [
		"Authorization: Bearer " + access_token,
		"Content-Type: application/json"
	]
	
	var error : Error = http_request.request(
	 "https://api.spotify.com/v1/" + uri,
	 headers,
	 request_type,
	 body)
	
	if(error != OK):
		push_error("API Request error: " + str(error))
	
	var request :Array = await http_request.request_completed
	http_request.queue_free()
	
	if(request[0] != HTTPRequest.RESULT_SUCCESS):
		push_error("API Request Failed on Godot side: " + str(request[0]))
	
	if(request[1] != 200):
		push_error("API Request Failed on Spotify side: " + str(request[1]))
	
	print("result: " + str(request[0]))
	print("response code " + str(request[1]))
	#print(request)
	return JSON.parse_string(request[3].get_string_from_utf8())
	


##basic cryptography to convert user credentials into a format spotify will accept
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
