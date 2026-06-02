extends Control

const ITEM_SCENE= preload("res://scenes/SearchItem.tscn")

@onready var text_field : LineEdit = $VBoxContainer/LineEdit
@onready var animation : AnimationPlayer = $AnimationPlayer
@onready var vbox : VBoxContainer = $VBoxContainer



func _on_line_edit_editing_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		animation.play("extend_line")
	else:
		animation.play_backwards("extend_line")



func _on_line_edit_text_submitted(new_text: String) -> void:
	var results : Array = await MusicManager.search_request(new_text)
	for result in results:
		var item : SearchItem = ITEM_SCENE.instantiate()
		var album_object : MusicManager.Album= await MusicManager.create_album(result["id"])
		vbox.add_child(item)
		item.setup(album_object.album_cover, album_object.info["name"], album_object.info["artists"][0]["name"])
		
