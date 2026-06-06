extends Node3D
@onready var record_holder = $Shelf/Node3D
@onready var loading_screen : Sprite2D = $Sprite2D
@onready var animation : AnimationPlayer = $AnimationPlayer
#load music into individual display records
func _ready() -> void:
	show_logo()
	await setup_display_albums()
	hide_logo()


func setup_display_albums():
	await MusicManager.initialize_display_records()
	var i : int = 0
	for record : Record in record_holder.get_children():
		if(!record.name.contains("Display")):
			continue
		MusicManager.load_record_data(record, MusicManager.all_albums[i])
		i+=1

func show_logo():
	var logo : Image = Image.load_from_file("res://assets/loading_screen.png")
	logo.resize(get_viewport().get_visible_rect().size.x, get_viewport().get_visible_rect().size.y)
	var logo_text : ImageTexture = ImageTexture.create_from_image(logo)
	loading_screen.position = get_viewport().get_visible_rect().get_center()
	loading_screen.texture = logo_text
	

func hide_logo():
	animation.play("loading_screen_fade")
	await get_tree().create_timer(2.0).timeout
	loading_screen.queue_free()
