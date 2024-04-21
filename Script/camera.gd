extends Camera2D

signal set_player_spawn_point(position)

# NOTE: fill player_spawn_points for each camera poses
const camera_poses = [Vector2(200, 5),
					Vector2(836,5),
					Vector2(1578, 5),
					Vector2(1900, -330),
					Vector2(2400, -230),
					Vector2(2920, -330)]
					
const player_spawn_points = [Vector2(-0, -11),
					Vector2(642,-11),
					Vector2(1334, -11),
					Vector2(1813, -348),
					Vector2(2208, -348),
					Vector2(2208, -348)]
## +x right -y up  -1 -> null
## [+x +y -x -y]
const camera_poses_adj_matrix = [[1,-1,-1,-1],
								 [2,-1,0,-1],
								 [-1,-1,1,3],
								 [4,2,-1,-1],
								 [5,-1,3,-1],
								 [-1,-1,4,-1]]
	
@export_category("Variables")
@export var shift_time := 0.15 # sec

var camera_pos_index = 0
var shifting = false	
	
func _ready():
	position = camera_poses[camera_pos_index]
	set_player_spawn_point.emit(player_spawn_points[0])

func _shift_camera(direction):
	var t = 0
	var start = camera_poses[camera_pos_index]
	var new_camera_pos_index = camera_poses_adj_matrix[camera_pos_index][direction]
	if new_camera_pos_index == -1: 
		return #dont shift when invalid space comes
	set_player_spawn_point.emit(player_spawn_points[new_camera_pos_index])
	var end = camera_poses[new_camera_pos_index]
	var shift_scale = 1 / shift_time  	
	shifting = true
	while t <= 1:
		await get_tree().create_timer(get_process_delta_time()).timeout
		t += shift_scale * get_process_delta_time()
		position = lerp(start, end, t)
	camera_pos_index = new_camera_pos_index
	shifting = false
