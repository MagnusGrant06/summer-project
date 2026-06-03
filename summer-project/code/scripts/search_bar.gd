extends Control

const ITEM_SCENE= preload("res://scenes/SearchItem.tscn")

@onready var text_field : LineEdit = $LineEdit
@onready var animation : AnimationPlayer = $AnimationPlayer
@onready var vbox : VBoxContainer = $VBoxContainer
@onready var loading_sprite : AnimatedSprite2D = $HBoxContainer/AnimatedSprite2D


func _on_line_edit_editing_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		animation.play("extend_line")
	else:
		animation.play_backwards("extend_line")



func _on_line_edit_text_submitted(new_text: String) -> void:
	loading_sprite.play("loading")
	loading_sprite.visible = true
	for n in vbox.get_children():
		n.queue_free()
	
	var results : Array = await MusicManager.search_request(new_text)
	for result in results:
		var item : SearchItem = ITEM_SCENE.instantiate()
		var album_object : MusicManager.Album= await MusicManager.create_album(result["id"])
		vbox.add_child(item)
		item.setup(album_object.album_cover, album_object.info["name"], album_object.info["artists"][0]["name"], album_object)
	
	loading_sprite.stop()
	loading_sprite.visible = false
	

func _process(_delta: float) -> void:
	if(Global.record_in_use):
		visible = true
	else:
		visible = false
