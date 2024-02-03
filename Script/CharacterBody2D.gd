extends CharacterBody2D

const SPEED = 300.0
const VERTICAL_SPEED = 300.0
const JUMP_VELOCITY = -400.0

const VERTICAL_VELOCITY_CAP = 1500.0 #NOTE: not used yet 

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

const MAX_STAMINA = 100.0
const STAMINA_DECAY_PER_SECOND = 20.0
const STAMINA_RECOVERY_RATE = 3 # seconds

var holding = false
var stamina = MAX_STAMINA

func _physics_process(delta):
	var on_wall = is_on_wall()
	var on_floor = is_on_floor()
	
	if Input.is_action_just_pressed("hold_surface") and on_wall:
		holding = true
		velocity.y = 0
	if Input.is_action_just_released("hold_surface"):
		holding = false
	
	var horizontal_direction = Input.get_axis("ui_left", "ui_right")
	if holding: # wall movement 
		var vertical_direction = Input.get_axis("ui_up", "ui_down")
		if vertical_direction:
			position.y += VERTICAL_SPEED * delta * vertical_direction
	else:
		velocity.y += gravity * delta # Add the gravity.
		if horizontal_direction:
			velocity.x = horizontal_direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and (on_wall or on_floor):
		velocity.y = JUMP_VELOCITY 
		velocity.x = JUMP_VELOCITY * horizontal_direction
		holding = false
	move_and_slide()
	# handle stamina
	if holding:
		stamina -= delta * STAMINA_DECAY_PER_SECOND
		if stamina <= 0:
			pass #TODO: add stamina recovery
			holding = false
