extends Node3D
@onready var hover_shader = load("res://hover_shader.gdshader")
@onready var case = $RigidBody3D/OuterCase
@onready var animator = $AnimationPlayer
@onready var camera = $"../../Camera3D"
var hovering = false

func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("click") && hovering):
		_on_mouse_clicked()

func _on_area_3d_mouse_entered() -> void:
	var newShader = ShaderMaterial.new()
	newShader.shader = hover_shader
	case.material_override = newShader
	if(!animator.is_playing()):
		animator.play("reveal_record")
	hovering = true


func _on_area_3d_mouse_exited() -> void:
	case.material_override = ShaderMaterial.new()
	if(animator.is_playing()):
		await animator.animation_finished
	animator.play_backwards("reveal_record")
	hovering = false

func _on_mouse_clicked() -> void:
	global_position = camera.global_position -Vector3(1.0,1.0,1.0) 
