extends Node3D
@onready var lid_animation = $AnimationPlayer
@onready var hover_shader = load("res://code/shaders/hover_shader.gdshader")
@onready var lid = $playerlid
@onready var collection_area_hitbox = $CollectionArea/CollisionShape3D
@onready var collection_area = $CollectionArea
@onready var disk_join = $DiskJoin
@onready var play_button_collision = $PlayButton/CollisionShape3D

#flags for changing player state
var mouse_entered = false
var lid_open = false
var play_botton_pressed = false
var currently_playing_song = false

var playing_song : AudioStreamPlayer

func _ready() -> void:
	collection_area_hitbox.disabled = true

func _process(_delta: float) -> void:
	check_for_disks()
	if(Input.is_action_just_pressed("click") && mouse_entered && lid_open):
		lid_animation.play_backwards("lid_open")
		lid_open = false
		collection_area_hitbox.disabled = true
		return
	if(Input.is_action_just_pressed("click") && mouse_entered && !lid_open):
		lid_animation.play("lid_open")
		lid_open = true
		collection_area_hitbox.disabled = false
		return

func _on_area_3d_mouse_entered() -> void:
	var newShader = ShaderMaterial.new()
	newShader.shader = hover_shader
	lid.material_override = newShader
	mouse_entered = true


func _on_area_3d_mouse_exited() -> void:
	lid.material_override = ShaderMaterial.new()
	mouse_entered = false
	

#check for disks entering zone to grab
#Possible TODO optimize
func check_for_disks() -> void:
	if(!lid_open): return
	for node : Node3D in collection_area.get_overlapping_bodies():
		if(!is_instance_of(node.get_parent(),RecordDisk)):continue
		if(node.get_parent().grabbed):continue
		node.get_parent().attach_body(self)

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if (event.is_action_pressed("click")):
		lid_animation.play("press_play")
		play_disk_music()
		

var i : int = 0

#play current disks music
func play_disk_music() -> void:
	var disk_child = get_child(get_children().size()-1)
	if( !(disk_child is RecordDisk) ):
		return
	MusicManager.play_album(disk_child.music)

func _on_song_finished() -> void:
	i+=1
