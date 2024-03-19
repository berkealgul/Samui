extends Node2D

signal player_dead()

const SPIKE_WIDTH = 8 # in pixels

@export var spike_count := 1

func _ready():
	#get_node("Area2D/CollisionShape2D").shape.size.x = spike_count * 4
	var col_shape = get_node("Area2D")
	var spike_sprite = get_node("Sprite2D")
	var spike_end = SPIKE_WIDTH * (spike_count/2)
	var spike_start = -spike_end
	var spike_pos = spike_start + (SPIKE_WIDTH / 2)
	spike_sprite.position.x = spike_pos 
	col_shape.position.x = spike_pos 
	for i in range(1, spike_count):
		spike_pos += SPIKE_WIDTH
		var spike = spike_sprite.duplicate(8)
		var shape = col_shape.duplicate(8)
		spike.position.x = spike_pos
		shape.position.x = spike_pos
		shape.body_entered.connect(_on_area_2d_body_entered)
		add_child(spike)
		add_child(shape)

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		player_dead.emit()
