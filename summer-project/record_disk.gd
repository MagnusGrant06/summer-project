extends Node3D

@onready var hover_shader = load("res://hover_shader.gdshader")
@onready var mesh = $RigidBody3D/Disk
@onready var parent_body = $RigidBody3D
@onready var phyisics_hitbox = $RigidBody3D/CollisionShape3D

@onready var master_scene = $"../../../.."

@onready var case_animation = $"../../AnimationPlayer"
@onready var case = $".."
var grabbed = false
var hovering = false
var revealed = false
func _process(_delta: float) -> void:
	_on_mouse_clicked()
	if(grabbed):
		global_position.x = get_viewport().get_mouse_position().x
		global_position.y = -get_viewport().get_mouse_position().y
		print(get_viewport().get_mouse_position())

func _on_area_3d_mouse_entered() -> void:
	var newShader = ShaderMaterial.new()
	newShader.shader = hover_shader
	mesh.material_overlay = newShader
	hovering = true

func _on_area_3d_mouse_exited() -> void:
	mesh.material_overlay = ShaderMaterial.new()
	hovering = false

func _on_mouse_clicked() -> void:
	if(!hovering):
		return
	if(Input.is_action_just_pressed("click") && !revealed):
		case_animation.play("reveal_disk")
		revealed = true
	if(Input.is_action_just_pressed("right_click")&&revealed):
		revealed = false
		case_animation.play_backwards("reveal_disk")
	if(Input.is_action_just_pressed("click") && revealed):
		grabbed = true
		case.freeze = false
		reparent(master_scene,true)
