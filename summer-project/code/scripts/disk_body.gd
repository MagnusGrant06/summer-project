extends RigidBody3D
var mouse_pos : Vector3
var grabbed : bool

func set_mouse_pos(pos : Vector3):
	mouse_pos = pos

func set_grabbed(grabbed_int : bool):
	grabbed = grabbed_int

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if(grabbed):
		state.linear_velocity = (mouse_pos - global_position) / state.step
		if(Input.is_action_pressed("w")):
			state.angular_velocity = Vector3(0,0,0)
			rotate_x(1.0/6.0)
		if(Input.is_action_pressed("s")):
			state.angular_velocity = Vector3(0,0,0)
			rotate_x(-1.0/6.0)
		if(Input.is_action_pressed("a")):
			state.angular_velocity = Vector3(0,0,0)
			rotate_y(-1.0/6.0)
		if(Input.is_action_pressed("d")):
			state.angular_velocity = Vector3(0,0,0)
			rotate_y(1.0/6.0)
	
