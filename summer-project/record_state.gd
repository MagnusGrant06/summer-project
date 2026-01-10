@abstract
class_name RecordState extends Node
var parent
@abstract
func _on_area_3d_mouse_entered() -> void
@abstract
func _on_area_3d_mouse_exited() -> void
@abstract
func _on_mouse_clicked() -> void


class StoredRecord extends RecordState:
	var hovering = false
	func _init(parent_record : Record) -> void:
		parent = parent_record
		
	func _on_area_3d_mouse_entered() -> void:
		var newShader = ShaderMaterial.new()
		newShader.shader = parent.hover_shader
		parent.case.material_override = newShader
		if(!parent.animator.is_playing()):
			parent.animator.play("reveal_record")
		hovering = true

	func _on_area_3d_mouse_exited() -> void:
		parent.case.material_override = ShaderMaterial.new()
		if(parent.animator.is_playing()):
			await parent.animator.animation_finished
		parent.animator.play_backwards("reveal_record")
		hovering = false

	func _on_mouse_clicked() -> void:
		if(Input.is_action_just_pressed("click") && hovering && !Global.record_in_use):
			var target_vector = Vector3(1.087,1.069,2.226)
			parent.global_position = target_vector
			parent.global_rotation = parent.camera.global_rotation
			parent.animator.stop()
			queue_free()
			parent.record_state = ViewingRecord.new(parent)
			Global.record_in_use = true


class ViewingRecord extends RecordState:
	var hovering = false
	var disk_peeked = false
	func _init(parent_record : Record) -> void:
		parent = parent_record
		parent.animator.stop()
		
	func _on_area_3d_mouse_entered() -> void:
		var newShader = ShaderMaterial.new()
		newShader.shader = parent.hover_shader
		parent.case.material_override = newShader
		hovering = true
	func _on_area_3d_mouse_exited() -> void:
		parent.case.material_override = ShaderMaterial.new()
		hovering = false
	func _on_mouse_clicked() -> void:
		if(!hovering):
			return
		if(Input.is_action_just_pressed("right_click")):
			parent.global_position = parent.base_position
			parent.global_rotation = parent.base_rotation
			queue_free()
			parent.record_state = StoredRecord.new(parent)
			Global.record_in_use = false
		if(Input.is_action_just_pressed("click")):
			if(!parent.animator.is_playing() && !disk_peeked):
				parent.animator.play("peek_disk")
				disk_peeked = true
			if(!parent.animator.is_playing() && disk_peeked):
				parent.animator.play_backwards("peek_disk")
				disk_peeked = false
		if(Input.is_action_just_pressed("scroll_up")):
			parent.global_rotation += Vector3(0.0,1.0/6.0,0.0)
		if(Input.is_action_just_pressed("scroll_down")):
			parent.global_rotation -= Vector3(0.0,1.0/6.0,0.0)
