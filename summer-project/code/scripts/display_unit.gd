extends Node3D

@onready var collection_area : Area3D = $Area3D
@onready var record_position : PinJoint3D = $PinJoint3D
var record_displaying : Record = null


func _process(_delta: float) -> void:
	print(collection_area.monitoring)
	if(record_displaying):
		record_displaying.physics_body.global_rotation += Vector3(0,0.01,0)


func _on_area_3d_body_entered(body: Node3D) -> void:
	var record := body.get_parent() as Record
	if(body.get_parent() is not Record):
		return
	
	record.physics_body.freeze = true
	record_displaying = record
	collection_area.set_deferred("monitoring",false)
	
	var target_position : Vector3 =  record_position.global_position
	record.global_position = target_position
	record.physics_body.global_position = target_position
	record.physics_body.global_rotation = Vector3(0,0,0)
	
	
func _on_area_3d_body_exited(body: Node3D) -> void:
	collection_area.set_deferred("monitoring",true)
	print("yeah")
