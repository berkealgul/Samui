extends Area2D

signal camera_shift(direction)

@export_category("Variables")
## direction 0: +x 1: +y 2: -x 3: -y
## direction_type 0:x 1:y 
@export_range (0, 1) var direction_type: int 

var body_enter_velocity = 0

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body_enter_velocity = body.velocity[direction_type]
		_emit_camera_shift_signal(body_enter_velocity)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		var body_exit_velociy = body.velocity[direction_type]
		if body_exit_velociy * body_enter_velocity < 0:
			_emit_camera_shift_signal(body_exit_velociy)

func _emit_camera_shift_signal(velocity):
	if velocity > 0:
		camera_shift.emit(direction_type)
	else:
		camera_shift.emit(direction_type + 2)


