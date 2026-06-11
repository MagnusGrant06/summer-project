class_name RecordDisk extends Node3D

@onready var hover_shader = load("res://code/shaders/hover_shader.gdshader")
@onready var mesh = $DiskBody/Disk
@onready var parent_body = $DiskBody
@onready var phyisics_hitbox = $DiskBody/CollisionShape3D

@onready var master_scene = $"../../../.."
@onready var camera = $"../../../../../Camera3D"
@onready var case_animation = $"../../AnimationPlayer"
@onready var case = $".."
@onready var parent : Record = $"../.."

var base_position : Vector3

var hovering = false

var revealed = false
var default = true
var grabbed = false
var at_rest : bool = false

var arbitrary_z = 1.0

var album_uri : String

var meshes_to_highlight : Array[MeshInstance3D] = []

func _ready() -> void:
	meshes_to_highlight.append($DiskBody/Disk)
	meshes_to_highlight.append($DiskBody/DetailDisk)
	meshes_to_highlight.append($DiskBody/DetailDisk2)
	base_position = global_position

func _process(_delta: float) -> void:
	_on_mouse_clicked()
	parent_body.set_grabbed(grabbed)
	if(grabbed):
		var camera_space2 = camera.project_position(get_viewport().get_mouse_position(),arbitrary_z)
		parent_body.set_mouse_pos(camera_space2)

##basic highlighting shader system for when hovering over a non grabbed disk
func _on_area_3d_mouse_entered() -> void:
	var newShader = ShaderMaterial.new()
	for cur_mesh : MeshInstance3D in meshes_to_highlight:
		if(grabbed):
			break
		newShader.shader = hover_shader
		cur_mesh.material_overlay = newShader
	hovering = true

func _on_area_3d_mouse_exited() -> void:
	for cur_mesh : MeshInstance3D in meshes_to_highlight:
		cur_mesh.material_overlay = ShaderMaterial.new()
	hovering = false

func _on_mouse_clicked() -> void:
	if(!hovering):
		return
	if(default):
		default_mouse_action()
	if(grabbed):
		grabbed_mouse_action()


func calculate_location() -> void:
	var camera_space2 = camera.project_position(get_viewport().get_mouse_position(),arbitrary_z)    #convert mouse position on screen to world position in scene
	global_position = camera_space2
	
	mesh.global_position = global_position
	mesh.global_rotation = global_rotation + Vector3(PI/2,0.0,0.0)

#very basic state machine changing mouse action depending on if the disk is grabbed or not
func default_mouse_action() -> void:
	if(Input.is_action_just_pressed("click") && revealed):
		for cur_mesh : MeshInstance3D in meshes_to_highlight:
			cur_mesh.material_overlay = ShaderMaterial.new()
		grabbed = true
		default = false
		at_rest = false
		Global.record_in_use = false
		parent_body.freeze = false
		reparent(master_scene,true)
		if( (parent.record_state is RecordState.ViewingRecord)):
			parent.record_state = await RecordState.EmptyRecord.new(parent)
	if(Input.is_action_just_pressed("click") && !revealed):
		case_animation.play("reveal_disk")
		revealed = true
	if(Input.is_action_just_pressed("right_click")&&revealed):
		revealed = false
		case_animation.play_backwards("reveal_disk")

	if(Input.is_action_just_pressed("right_click") && at_rest):
		parent_body.freeze = true
		global_position = base_position
		var target_pos : Vector3 = parent.base_position
		global_position = target_pos
		parent_body.global_position = target_pos
		var target_rot : Vector3 = parent.base_rotation
		global_rotation = target_rot
		parent_body.global_rotation = target_rot
		default = true
		at_rest = false
		parent.animator.play("RESET")
		reparent(parent.physics_body)
		parent.disk = self


func grabbed_mouse_action() -> void:
	if(Input.is_action_just_pressed("right_click")):
		grabbed = false
		default = true
		at_rest = true
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
