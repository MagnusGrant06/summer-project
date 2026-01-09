class_name Record extends Node3D
@onready var hover_shader = load("res://hover_shader.gdshader")
@onready var case = $RigidBody3D/OuterCase
@onready var animator = $AnimationPlayer
@onready var camera = $"../../Camera3D"
@onready var parent_record = $"."
var record_state
func _ready() -> void:
	record_state = RecordState.StoredRecord.new(global_position,hover_shader,case,animator,camera)

func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("click") && record_state.hovering):
		_on_mouse_clicked()
	global_position = record_state.parent_position

func _on_area_3d_mouse_entered() -> void:
	record_state._on_area_3d_mouse_entered()

func _on_area_3d_mouse_exited() -> void:
	record_state._on_area_3d_mouse_exited()

func _on_mouse_clicked() -> void:
	record_state._on_mouse_clicked()
