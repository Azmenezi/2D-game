extends CharacterBody2D


@export var SPEED = 600
@export var JUMP_VELOCITY = -700
@export var gravity = 30
var onGround = 0
var space_pressed_time: float
var animated_sprite
func _ready():
	space_pressed_time = -1.0
	animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	#crouching
	if Input.is_action_pressed("crouch"):
		animated_sprite.play("crouch")
		SPEED = 300
	if Input.is_action_just_released("crouch"):
		SPEED = 600
	
	#Animation checker
	if velocity.x == 0 and velocity.y == 0 and !Input.is_action_pressed("crouch"):
		animated_sprite.play("idle")
	else: if velocity.x == 600 and velocity.y == 0:
		animated_sprite.flip_h = false
		animated_sprite.play("running")
	else: if velocity.x == -600 and velocity.y == 0:
		animated_sprite.flip_h = true
		animated_sprite.play("running")
	else: if velocity.x == 600 and velocity.y < 0:
		animated_sprite.flip_h = false
		animated_sprite.play("jumping up")
	else: if velocity.x == -600 and velocity.y < 0:
		animated_sprite.flip_h = true
		animated_sprite.play("jumping up")
	else: if velocity.x == 600 and velocity.y > 0:
		animated_sprite.flip_h = false
		animated_sprite.play("jumping down")
	else: if velocity.x == -600 and velocity.y > 0:
		animated_sprite.flip_h = true
		animated_sprite.play("jumping down")
	else: if  velocity.y < 0 :
		animated_sprite.play("jumping up")
	else: if  velocity.y > 0 :
		animated_sprite.play("jumping down")
	else:
		animated_sprite.stop()
	
	
	
	# Add the gravity.
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > 1000:
			velocity.y = 1000
			

	# Handle Jump.
	if onGround < 1:
		if Input.is_action_just_pressed("jump") :
			onGround += 1
			velocity.y = JUMP_VELOCITY
			
	
	
	if is_on_floor():
		onGround=0
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
	if Input.is_action_just_pressed("dash"):
		if direction == -1:
			velocity.x += -200
		else: if direction == 1:
			velocity.x += 200
	
	#Handle double jump
	if onGround < 2:
		if Input.is_action_just_pressed("jump"):
			onGround += 1
			velocity.y = JUMP_VELOCITY
	#Handle jumps before touching the gorund
	if Input.is_action_just_pressed("jump"):
		space_pressed_time = Time.get_ticks_msec() / 250.0
	if space_pressed_time >= 0 and Time.get_ticks_msec() / 250.0 - space_pressed_time <= 0.25:
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
	else:
			space_pressed_time = -0.25
			
	
	print(velocity.x)
