extends Node3D
@onready var record_holder = $Shelf/Node3D
@onready var loading_screen : Sprite2D = $Sprite2D
@onready var animation : AnimationPlayer = $AnimationPlayer
@onready var background_texture : TextureRect = $TextureRect

#load music into individual display records
func _ready() -> void:
	MusicManager.user_connected.connect(hide_logo)
	show_logo()
	await setup_display_albums()

func setup_display_albums():
	await MusicManager.initialize_display_records()
	var i : int = 0
	for record : Record in record_holder.get_children():
		if(!record.name.contains("Display")):
			continue
		MusicManager.load_record_data(record, MusicManager.all_albums[i])
		i+=1

##loading screen method to wait until user has logged into spotify
##then plays loading sequence to hide initial slow API calls
func show_logo():
	var background : Image =Image.load_from_file("res://assets/empty_loading_screen.png")
	var logo : Image = Image.load_from_file("res://assets/loading_screen_2.png")
	
	logo.resize(get_viewport().get_visible_rect().size.x as int , get_viewport().get_visible_rect().size.y as int)
	background.resize(get_viewport().get_visible_rect().size.x as int, get_viewport().get_visible_rect().size.y as int)
	
	var logo_text : ImageTexture = ImageTexture.create_from_image(logo)
	var background_text : ImageTexture = ImageTexture.create_from_image(background)
	loading_screen.position = get_viewport().get_visible_rect().get_center()
	background_texture.position = Vector2(0,0)
	
	background_texture.texture = background_text
	loading_screen.texture = logo_text
	
	

func hide_logo():
	animation.play("loading_screen_fade")
	await get_tree().create_timer(10.0).timeout
	loading_screen.queue_free()
	background_texture.queue_free()
