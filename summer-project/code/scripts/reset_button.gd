extends Button
@onready var anim : AnimatedSprite2D = $AnimatedSprite2D

##small class to trasmit animation and resetting data to and from the button scene placed in main scene

func _on_mouse_entered() -> void:
	anim.play("spin")


func _on_mouse_exited() -> void:
	anim.play_backwards("spin")


func _on_pressed() -> void:
	get_tree().reload_current_scene()
