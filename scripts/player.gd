extends CharacterBody2D


@export var SPEED = 600
@export var JUMP_VELOCITY = -700
@export var gravity = 30
@export var health = 100

var onGround = 0
var space_pressed_time: float
var animated_sprite

var dashing = false
var dash_duration = 0.2
var dash_timer = 0.0

func _ready():
	space_pressed_time = -0.25 
	animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	
	animationChanger()
	
	handleJumping()
	
	# Add the gravity.
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > 1000:
			velocity.y = 1000
			
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if Input.is_action_just_pressed("dash") and !dashing:
		dashing = true
		dash_timer = 3.0
		if direction == -1:
			velocity.x = -8000
		elif direction == 1:
			velocity.x = 8000
	if dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			dashing = false
			velocity.x = direction * SPEED
	move_and_slide()
	
	
			
	
	print(velocity.x)





func animationChanger():
	#crouching
	if velocity.x > 0 and Input.is_action_pressed("crouch") and velocity.y == 0:
		print("Crouching to the right")
		animated_sprite.flip_h = false
		animated_sprite.play("crouch")
		SPEED = 300
	elif  velocity.x < 0 and Input.is_action_pressed("crouch") and velocity.y == 0:
		print("Crouching to the left")
		animated_sprite.flip_h = true
		animated_sprite.play("crouch")
	elif  velocity.x == 0 and Input.is_action_pressed("crouch") and velocity.y == 0:
		print("Crouching ")
		animated_sprite.play("crouch")
	if Input.is_action_just_released("crouch") or velocity.y != 0:
		SPEED = 600
	
	#Animation checker
	if velocity.x == 0 and velocity.y == 0 and !Input.is_action_pressed("crouch"):
		animated_sprite.play("idle")
	elif  velocity.x == 600 and velocity.y == 0:
		animated_sprite.flip_h = false
		animated_sprite.play("running")
	elif  velocity.x == -600 and velocity.y == 0:
		animated_sprite.flip_h = true
		animated_sprite.play("running")
	elif  velocity.x == 600 and velocity.y < 0:
		animated_sprite.flip_h = false
		animated_sprite.play("jumping up")
	elif  velocity.x == -600 and velocity.y < 0:
		animated_sprite.flip_h = true
		animated_sprite.play("jumping up")
	elif  velocity.x == 600 and velocity.y > 0:
		animated_sprite.flip_h = false
		animated_sprite.play("jumping down")
	elif  velocity.x == -600 and velocity.y > 0:
		animated_sprite.flip_h = true
		animated_sprite.play("jumping down")
	elif   velocity.y < 0 :
		animated_sprite.play("jumping up")
	elif   velocity.y > 0 :
		animated_sprite.play("jumping down")
	elif !Input.is_action_pressed("crouch"):
		animated_sprite.stop()

func handleJumping():
	# Handle Jump.
	if onGround < 1:
		if Input.is_action_just_pressed("jump") :
			onGround += 1
			velocity.y = JUMP_VELOCITY
	if is_on_floor():
		onGround=0
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


