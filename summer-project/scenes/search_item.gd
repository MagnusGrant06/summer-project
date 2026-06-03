class_name SearchItem extends Control
@onready var album_cover : TextureRect = $Button/AlbumCover
@onready var album_name : Label = $Button/AlbumName
@onready var artist_name : Label = $Button/ArtistName

var album_object : MusicManager.Album
func _ready() -> void:
	print("somehting happening")

func setup(cover : Image, album : String, artist : String, album_obj : MusicManager.Album) -> void:
	album_name.text = album
	artist_name.text = artist
	album_cover.texture = ImageTexture.create_from_image(cover)
	album_cover.size.x = 67
	album_cover.size.y = 67
	
	#album for internal user
	album_object = album_obj


func _on_button_pressed() -> void:
	MusicManager.switch_album(album_object)
