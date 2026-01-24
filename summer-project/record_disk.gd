class_name RecordDisk extends Node3D

@onready var hover_shader = load("res://hover_shader.gdshader")
@onready var mesh = $RigidBody3D/Disk
@onready var parent_body = $RigidBody3D
@onready var phyisics_hitbox = $RigidBody3D/CollisionShape3D

@onready var master_scene = $"../../../.."
@onready var camera = $"../../../../../Camera3D"
@onready var case_animation = $"../../AnimationPlayer"
@onready var case = $".."

var grabbed = false
var hovering = false
var revealed = false
var default = true
var arbitrary_z = 1.0

var album : MusicManager.Album

func _process(_delta: float) -> void:
	_on_mouse_clicked()
	check_for_input()
	if(grabbed):
		calculate_location()
		global_rotation.z = 0.0


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
	if(grabbed):
		grabbed_mouse_action()
	if(default):
		default_mouse_action()

func calculate_location() -> void:
	var camera_space2 = camera.project_position(get_viewport().get_mouse_position(),arbitrary_z)
	global_position = camera_space2
	mesh.global_position = global_position
	mesh.global_rotation = global_rotation + Vector3(PI/2,0.0,0.0)

func default_mouse_action() -> void:
	if(Input.is_action_just_pressed("click") && revealed):
		grabbed = true
		default = false
		case.freeze = false
		reparent(master_scene,true)
		reset_disk()
	if(Input.is_action_just_pressed("click") && !revealed):
		case_animation.play("reveal_disk")
		revealed = true
	if(Input.is_action_just_pressed("right_click")&&revealed):
		revealed = false
		case_animation.play_backwards("reveal_disk")

func grabbed_mouse_action() -> void:
	if(Input.is_action_just_pressed("right_click")):
		grabbed = false
		default = true
		parent_body.freeze = false
	if(Input.is_action_just_pressed("scroll_up")):
		arbitrary_z += 0.2
	if(Input.is_action_just_pressed("scroll_down")):
		arbitrary_z -= 0.2

func check_for_input() -> void:
	if(!grabbed):
		return
	if(Input.is_action_pressed("w")):
		rotate_x(1.0/6.0)
	if(Input.is_action_pressed("s")):
		rotate_x(-1.0/6.0)
	if(Input.is_action_pressed("a")):
		rotate_y(-1.0/6.0)
	if(Input.is_action_pressed("d")):
		rotate_y(1.0/6.0)

func reset_disk() -> void:
	parent_body.freeze = true
	parent_body.global_position = global_position
	phyisics_hitbox.global_rotation = global_rotation - Vector3(PI/2,0.0,0.0)
	
func attach_body(parent: Node3D) -> void:
	reparent(parent)
	parent_body.freeze = true
	global_position = parent.disk_join.global_position
	global_rotation = Vector3(PI/2,0.0,0.)
	parent.disk_join.node_b = "."
