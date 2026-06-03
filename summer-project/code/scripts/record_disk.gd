class_name RecordDisk extends Node3D

@onready var hover_shader = load("res://code/shaders/hover_shader.gdshader")
@onready var mesh = $DiskBody/Disk
@onready var parent_body = $DiskBody
@onready var phyisics_hitbox = $DiskBody/CollisionShape3D

@onready var master_scene = $"../../../.."
@onready var camera = $"../../../../../Camera3D"
@onready var case_animation = $"../../AnimationPlayer"
@onready var case = $".."
@onready var parent= $"../.."

var grabbed = false
var hovering = false
var revealed = false
var default = true
var arbitrary_z = 1.0

var album_uri : String

func _process(_delta: float) -> void:
	_on_mouse_clicked()
	parent_body.set_grabbed(grabbed)
	if(grabbed):
		var camera_space2 = camera.project_position(get_viewport().get_mouse_position(),arbitrary_z)
		parent_body.set_mouse_pos(camera_space2)

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
	var camera_space2 = camera.project_position(get_viewport().get_mouse_position(),arbitrary_z)    #convert mouse position on screen to world position in scene
	global_position = camera_space2
	
	mesh.global_position = global_position
	mesh.global_rotation = global_rotation + Vector3(PI/2,0.0,0.0)

#very basic state machine changing mouse action depending on if the disk is grabbed or not
func default_mouse_action() -> void:
	if(Input.is_action_just_pressed("click") && revealed):
		grabbed = true
		default = false
		Global.record_in_use = false
		parent_body.freeze = false
		reparent(master_scene,true)
		if( !(parent.record_state is RecordState.EmptyRecord)):
			parent.record_state = RecordState.EmptyRecord.new(parent)
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
	if(Input.is_action_just_pressed("scroll_up")):
		arbitrary_z += 0.2
	if(Input.is_action_just_pressed("scroll_down")):
		arbitrary_z -= 0.2

func reset_disk() -> void:
	parent_body.global_position = global_position
	phyisics_hitbox.global_rotation = global_rotation - Vector3(PI/2,0.0,0.0)

#safe way to join disk to either main scene, record player, or back into record
func attach_body(new_parent: Node3D) -> void:
	grabbed = false
	default = true
	reparent(new_parent)
	parent_body.sleeping = true
	parent_body.freeze = true
	parent_body.global_position = new_parent.disk_join.global_position
	parent_body.global_rotation = Vector3(PI/2,0.0,0.0)
	new_parent.disk_join.node_b = "."
