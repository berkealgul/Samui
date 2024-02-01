extends Area2D

signal camera_shift(direction)

@export_category("Variables")
## direction 0: +x 1: +y 2: -x 3: -y
## direction_type 0:x 1:y 
@export_range (0, 1) var direction_type: int 

func _on_body_entered(body):
	if body.is_in_group("Player"):
		if body.velocity[direction_type] > 0:
			camera_shift.emit(direction_type)
		else:
			camera_shift.emit(direction_type + 2)
			
