extends Node3D
@onready var lid_animation = $AnimationPlayer
@onready var hover_shader = load("res://hover_shader.gdshader")
@onready var lid = $playerlid
@onready var collection_area_hitbox = $CollectionArea/CollisionShape3D
@onready var collection_area = $CollectionArea
@onready var disk_join = $DiskJoin
@onready var play_button_collision = $PlayButton/CollisionShape3D

var mouse_entered = false
var lid_open = false
var play_botton_pressed = false
var currently_playing_song = false

var playing_song : AudioStreamPlayer

func _ready() -> void:
	collection_area_hitbox.disabled = true
func _process(_delta: float) -> void:
	play_disk_music()
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
	

func _on_collection_area_body_entered(body: Node3D) -> void:
	var body_record = body.get_parent()
	if(!(body_record is RecordDisk)):
		return
	body_record.attach_body(self)


func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if (event.is_action_pressed("click")):
		lid_animation.play("press_play")
		play_botton_pressed  = true

var i : int = 0

func play_disk_music() -> void:
	if(!play_botton_pressed):
		return
	var disk_child = get_child(get_children().size()-1)
	if( !(disk_child is RecordDisk) ):
		return
	var current_songs : Array[AudioStreamPlayer] = disk_child.album.songs
	disk_child.global_rotation.y += deg_to_rad(0.0001)
	playing_song = current_songs[i]
	if(playing_song.finished.get_connections().size() <1):
		playing_song.finished.connect(_on_song_finished)
	if(!playing_song.playing):
		playing_song.play()
	if(Input.is_action_just_pressed("skip")):
		playing_song.stop()
		i+=1

func _on_song_finished() -> void:
	i+=1
