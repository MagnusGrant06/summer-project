class_name SearchItem extends Control
@onready var album_cover : TextureRect = $Button/AlbumCover
@onready var album_name : Label = $Button/AlbumName
@onready var artist_name : Label = $Button/ArtistName

func _ready() -> void:
	print("somehting happening")

func setup(cover : Image, album : String, artist : String) -> void:
	print(album)
	print(artist)
	album_name.text = album
	artist_name.text = artist
	album_cover.texture = ImageTexture.create_from_image(cover)
	album_cover.size.x = 70
	album_cover.size.y = 70
