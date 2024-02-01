extends Camera2D

const camera_poses = [Vector2(144, -11),
					Vector2(778,-11),
					Vector2(778, -325)]

## +x right -y up  -1 -> null
## [+x +y -x -y]
const camera_poses_adj_matrix = [[1,-1,-1,-1],
								 [-1,-1,0,2],
								[-1,1,-1,1]]
	
@export_category("Variables")
@export var shift_time := 0.25 # sec

var camera_pos_index = 0
var shifting = false	
	
func _ready():
	position = camera_poses[0]

func _shift_camera(direction):
	if shifting:
		return
	var t = 0
	var start = camera_poses[camera_pos_index]
	camera_pos_index = camera_poses_adj_matrix[camera_pos_index][direction]
	var end = camera_poses[camera_pos_index]
	var shift_scale = 1 / shift_time 
	shifting = true
	while t <= 1:
		await get_tree().create_timer(get_process_delta_time()).timeout
		t += shift_scale * get_process_delta_time()
		position = lerp(start, end, t)
	shifting = false
