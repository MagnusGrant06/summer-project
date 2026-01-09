@abstract
class_name RecordState extends Node
var parent_position
var parent_shader
var parent_mesh
var parent_animation
var parent_camera
@abstract
func _on_area_3d_mouse_entered() -> void
@abstract
func _on_area_3d_mouse_exited() -> void
@abstract
func _on_mouse_clicked() -> void


class StoredRecord extends RecordState:
	var hovering = false
	
	func _init(position,shader,mesh,animation,camera) -> void:
		parent_position = position
		parent_shader = shader
		parent_mesh = mesh
		parent_animation = animation
		parent_camera = camera
		
	
	func _process(delta: float) -> void:
		print("parent_position")
	func _on_area_3d_mouse_entered() -> void:
		var newShader = ShaderMaterial.new()
		newShader.shader = parent_shader
		parent_mesh.material_override = newShader
		if(!parent_animation.is_playing()):
			parent_animation.play("reveal_record")
		hovering = true
	func _on_area_3d_mouse_exited() -> void:
		parent_mesh.material_override = ShaderMaterial.new()
		if(parent_animation.is_playing()):
			await parent_animation.animation_finished
		parent_animation.play_backwards("reveal_record")
		hovering = false

	func _on_mouse_clicked() -> void:
		var target_vector = Vector3(1.087,1.069,2.226)
		parent_position = target_vector
		parent_position = parent_camera.global_rotation
