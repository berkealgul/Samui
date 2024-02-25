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

# sprites
var sLeft_Walk = 0
var sRight_Walk = 0

# animations
var idleAnim = 0

func _ready():
	sLeft_Walk = get_node("LeftWalkSprite")
	sRight_Walk = get_node("RightWalkSprite")
	idleAnim = get_node("IdleAnimPlayer")
	idleAnim.play() 

func _process(delta):
	if state == MOVEMENT_STATE.IDLE:
		if not idleAnim.is_playing():
			idleAnim.play()
	elif state == MOVEMENT_STATE.WALKING:
		pass
		idleAnim.stop()
		if velocity.x > 0:
			sRight_Walk.visible = true
			sLeft_Walk.visible = false
		else:
			sRight_Walk.visible = false
			sLeft_Walk.visible = true

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
		elif Input.is_action_just_pressed("ui_accept") and state != MOVEMENT_STATE.JUMPING and on_floor:
			velocity.x = -JUMP_VELOCITY *  horizontal_direction
			jumping_time = 0
			state = MOVEMENT_STATE.JUMPING
		if (Input.is_action_just_released("hold_surface") or not on_wall) and state == MOVEMENT_STATE.CLIMBING:
			state = MOVEMENT_STATE.IDLE
		if not Input.is_action_pressed("ui_accept") and jumping_time > MIN_JUMP_TIME and state == MOVEMENT_STATE.JUMPING:
			state = MOVEMENT_STATE.IDLE
	
	# refresh stats
	if on_floor and state == MOVEMENT_STATE.IDLE:
		stamina = MAX_STAMINA
		remaining_dashes = DEFAULT_CONSECUTIVE_DASH_COUNT
		state = MOVEMENT_STATE.WALKING
	
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

func _on_set_player_spawn_point(position):
	spawn_point = position

func _on_player_dead():
	position = spawn_point
