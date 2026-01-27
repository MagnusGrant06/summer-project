class_name Record extends Node3D
@onready var hover_shader = load("res://hover_shader.gdshader")
@onready var case = $RigidBody3D/OuterCase
@onready var animator = $AnimationPlayer
@onready var camera = $"../../../Camera3D"
@onready var parent_record = $"."
@onready var disk = $RigidBody3D/RecordDisk
@onready var physics_body : RigidBody3D = $RigidBody3D

var base_position
var base_rotation
var dummy_record

var record_state
func _ready() -> void:
	dummy_record = self
	base_position = global_position
	base_rotation = global_rotation
	record_state = RecordState.StoredRecord.new(dummy_record)
	animator.play_backwards("reveal_record")

func _process(_delta: float) -> void:
	_on_mouse_clicked()

func _on_area_3d_mouse_entered() -> void:
	record_state._on_area_3d_mouse_entered()

func _on_area_3d_mouse_exited() -> void:
	record_state._on_area_3d_mouse_exited()

func _on_mouse_clicked() -> void:
	record_state._on_mouse_clicked()
