extends Node3D

@onready var collection_area : Area3D = $Area3D
@onready var record_position : PinJoint3D = $PinJoint3D
@onready var light : SpotLight3D = $SpotLight3D
@onready var player = $"../Player"
var record_displaying : Record = null
var is_positioning : bool = false


func _process(_delta: float) -> void:
	if(record_displaying && player.currently_playing_song):
		record_displaying.physics_body.global_rotation += Vector3(0,0.01,0)

##attach record to pinjoint in display loosley and spin
func _on_area_3d_body_entered(body: Node3D) -> void:
	var record := body.get_parent() as Record
	if(body.get_parent() is not Record):
		return
	is_positioning = true
	collection_area.monitoring = false
	
	record_displaying = record
	record.physics_body.freeze = true
	record.physics_body.set_deferred("global_rotation", Vector3(0,0,0))
	
	var target_position : Vector3 =  record_position.global_position
	record.set_deferred("global_position", target_position)
	record.physics_body.set_deferred("global_position", target_position)
	light.light_color = record.mesh_color
	
	is_positioning = false
	

##reset record and display when record is removed
func _on_area_3d_body_exited(body: Node3D) -> void:
	if(is_positioning):
		return
	if(body.get_parent() is not Record):
		return
	light.light_color = Color.BLACK
	collection_area.set_deferred("monitoring",true)
	record_displaying = null
