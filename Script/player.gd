extends CharacterBody2D

enum MOVEMENT_STATE {IDLE, WALKING, DASHING, CLIMBING, JUMPING}

const MAX_STAMINA = 100.0

const DEFAULT_CONSECUTIVE_DASH_COUNT = 1
const VERTICAL_VELOCITY_CAP = 1500.0 #NOTE: not used yet 

@export_category("Movement Parameters")
const SPEED = 150.0
const CLIMB_SPEED = 200.0
const JUMP_VELOCITY = -250.0
const MAX_JUMP_TIME = 0.25
const MIN_JUMP_TIME = 0.05
const WALL_FALL_SPEED = 150

@export_category("Dash Parameters")
const DASH_TIME = 0.1
const DASH_VELOCITY = 500

@export_category("Stamina Parameters")
const STAMINA_DECAY_PER_SECOND = 20.0
const STAMINA_RECOVERY_RATE = 3 # seconds

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var dashing_time = 0
var jumping_time = 0
var remaining_dashes = DEFAULT_CONSECUTIVE_DASH_COUNT
var stamina = MAX_STAMINA
var state = MOVEMENT_STATE.IDLE
var spawn_point = Vector2(0,0)
var sprite_rotation = 0

@onready var animation_player = $AnimPlayer
@onready var sprite_anchor = $SpriteAnchor

func _ready():
	animation_player.play("Idle")

func update_animation():
	var vx = velocity[0]
	var vy = velocity[1]
	var anim = "Move"
	if vy > 0:
		anim += "_Down" 
	elif vy < 0:
		anim += "_Up" 
	if vx > 0:
		anim += "_Right" 
	elif vx < 0:
		anim += "_Left" 
	
	if anim == "Move":
		anim = "Idle"
	
	if anim != animation_player.current_animation:
		animation_player.play(anim)
	
func _physics_process(delta):
	var on_wall = is_on_wall()
	var on_floor = is_on_floor()
	var horizontal_direction = Input.get_axis("ui_left", "ui_right")
	var vertical_direction = Input.get_axis("ui_up", "ui_down")
	
	#TODO: Fix bug: cant hold while on floor
	
	if state != MOVEMENT_STATE.DASHING:
		if Input.is_action_just_pressed("dash") and remaining_dashes > 0:
			velocity.y = 0 
			velocity.x = horizontal_direction * DASH_VELOCITY
			state = MOVEMENT_STATE.DASHING
			dashing_time = 0
			remaining_dashes -= 1
		elif Input.is_action_just_pressed("hold_surface") and state != MOVEMENT_STATE.CLIMBING:
			state = MOVEMENT_STATE.CLIMBING
			velocity.y = 0
		elif Input.is_action_just_pressed("ui_accept") and state != MOVEMENT_STATE.JUMPING and (on_floor or on_wall):
			velocity.x = -JUMP_VELOCITY *  horizontal_direction
			jumping_time = 0
			state = MOVEMENT_STATE.JUMPING
		if (Input.is_action_just_released("hold_surface") or not on_wall) and state == MOVEMENT_STATE.CLIMBING:
			state = MOVEMENT_STATE.IDLE
		if not Input.is_action_pressed("ui_accept") and jumping_time > MIN_JUMP_TIME and state == MOVEMENT_STATE.JUMPING and not is_on_ceiling():
			state = MOVEMENT_STATE.IDLE
	
	# refresh stats
	if on_floor and state == MOVEMENT_STATE.IDLE:
		stamina = MAX_STAMINA
		remaining_dashes = DEFAULT_CONSECUTIVE_DASH_COUNT
		state = MOVEMENT_STATE.WALKING
	
	# reflesh rotation if not climbing
	if state != MOVEMENT_STATE.CLIMBING and sprite_rotation != 0:
		sprite_anchor.rotate(-sprite_rotation)
		sprite_rotation = 0
	# decide climb direction and rotate sprite accordingly
	if state == MOVEMENT_STATE.CLIMBING and sprite_rotation == 0:
		if get_slide_collision_count() != 0:
			sprite_rotation = get_slide_collision(0).get_normal()[0] * PI/2
			sprite_anchor.rotate(sprite_rotation)
	
	match state:
		MOVEMENT_STATE.DASHING:
			dashing_time += delta
			if dashing_time > DASH_TIME:
				state = MOVEMENT_STATE.IDLE
		MOVEMENT_STATE.JUMPING:
				jumping_time += delta
				velocity.y = JUMP_VELOCITY 
				if jumping_time > MAX_JUMP_TIME:
					state = MOVEMENT_STATE.IDLE
		MOVEMENT_STATE.CLIMBING: # wall movement 
			if vertical_direction:
				velocity.y = CLIMB_SPEED * vertical_direction
			else:
				velocity.y = move_toward(velocity.y, 0, CLIMB_SPEED)
			# handle stamina
			#stamina -= delta * STAMINA_DECAY_PER_SECOND
			if stamina <= 0:
				state = MOVEMENT_STATE.IDLE
		MOVEMENT_STATE.WALKING:
			# normal movement
			if horizontal_direction:
				velocity.x = horizontal_direction * SPEED
			else: velocity.x = move_toward(velocity.x, 0, SPEED) # smooth stop
			if on_wall and velocity.x != 0:
				velocity.y = min(WALL_FALL_SPEED, velocity.y + gravity * delta)
			else: velocity.y += gravity * delta
		MOVEMENT_STATE.IDLE: # only gravity for idle
			if horizontal_direction:
				velocity.x = horizontal_direction * SPEED
			else: velocity.x = move_toward(velocity.x, 0, SPEED) # smooth stop
			if on_wall and velocity.x != 0:
				velocity.y = min(WALL_FALL_SPEED, velocity.y + gravity * delta)
			else: velocity.y += gravity * delta
	move_and_slide()	
	update_animation()

func _on_set_player_spawn_point(position):
	spawn_point = position

func _on_player_dead():
	position = spawn_point
