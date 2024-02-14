extends AnimatableBody2D

"""
Platform that moves on only(for now) horizontal direction 
"""

@export var moving_distance := 200
@export var speed := 0.4

var pos1 := Vector2(0, 0)
var pos2 := Vector2(0, 0)
var t = 0
var dir = 1

func _ready():
	pos1 = position
	pos2 = pos1 + Vector2(moving_distance, 0)

func _physics_process(delta):
	position = lerp(pos1, pos2, t)
	t += speed * delta * dir
	if t >= 1 and dir == 1:
		dir = -1
	if t <= 0 and dir == -1:
		dir = 1
