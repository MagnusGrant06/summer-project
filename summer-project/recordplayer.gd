extends Node3D
@onready var lid_animation = $AnimationPlayer
@onready var hover_shader = load("res://hover_shader.gdshader")
@onready var lid = $playerlid
var mouse_entered = false;
var lid_open = false

func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("click") && mouse_entered && lid_open):
		lid_animation.play_backwards("lid_open")
		lid_open = false
		return
	if(Input.is_action_just_pressed("click") && mouse_entered && !lid_open):
		lid_animation.play("lid_open")
		lid_open = true
		return

func _on_area_3d_mouse_entered() -> void:
	var newShader = ShaderMaterial.new()
	newShader.shader = hover_shader
	lid.material_override = newShader
	mouse_entered = true


func _on_area_3d_mouse_exited() -> void:
	lid.material_override = ShaderMaterial.new()
	mouse_entered = false


	
