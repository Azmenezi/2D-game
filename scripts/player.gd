extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var dash = $Dash
@onready var space_pressed_time = -0.25 
@onready var crouchRayCast1 = $CrouchRayCast_1
@onready var crouchRayCast2 = $CrouchRayCast_2

@export var normalSpeed = 600
@export var JUMP_VELOCITY = -700
@export var gravity = 30
@export var health = 100

var dashSpeed = normalSpeed * 3
var dashLength = 0.4
var dashDirection = 0
var onGround = 0
var speed 

var stuckUnderObject = false
var crouched = false
var dashing = false
func _physics_process(_delta):
	# Add the animation.
	animationChanger()
	
	handleCouching()
	# Add the ability of dashing.
	handleDashing()
	# Add the jumping and double jumping funciton.
	handleJumping()
	# Add the gravity.
	gravityFunc()
	# Add movement and check for dashing
	movement()
	
	handleAboveCrouching()
	
	handleCrouching()
	
	move_and_slide()


func handleAboveCrouching() -> bool:
	var result = !crouchRayCast1.is_colliding() and !crouchRayCast2.is_colliding()
	return result

func handleCrouching():
	if Input.is_action_pressed("crouch") and velocity.y == 0 and !dash.is_dashing():
		crouch()
	elif Input.is_action_just_released("crouch"):
		if handleAboveCrouching():
			stand()
		else:
			if stuckUnderObject == false:
				stuckUnderObject = true
	if stuckUnderObject and handleAboveCrouching() and !Input.is_action_pressed("crouch"):
		stand()
		stuckUnderObject = false

func handleCouching():
	#crouching
	if velocity.x > 0 and crouched == true and velocity.y == 0 and !dash.is_dashing():
		animated_sprite.flip_h = false
		animated_sprite.play("crouching movement")
		normalSpeed = 300
	elif  velocity.x < 0 and crouched == true and velocity.y == 0 and !dash.is_dashing():
		animated_sprite.flip_h = true
		animated_sprite.play("crouching movement")
		normalSpeed = 300
	elif  velocity.x == 0 and crouched == true and velocity.y == 0 and !dash.is_dashing():
		animated_sprite.play("crouch")
	if crouched == false or velocity.y != 0:
		normalSpeed = 600

func animationChanger():
	#Animation checker
	if   velocity.x == 600 and velocity.y == 0:
		animated_sprite.flip_h = false
		animated_sprite.play("running")
	elif  velocity.x == -600 and velocity.y == 0:
		animated_sprite.flip_h = true
		animated_sprite.play("running")
	elif dash.is_dashing() and velocity.y == 0 :
		animated_sprite.play("dashing")
	elif dash.is_dashing() and velocity.y != 0 :
		animated_sprite.play("dashing")
	elif  velocity.x == 600 and velocity.y < 0  and onGround < 2:
		animated_sprite.flip_h = false
		animated_sprite.play("jumping up")
	elif  velocity.x == -600 and velocity.y < 0 and onGround < 2 :
		animated_sprite.flip_h = true
		animated_sprite.play("jumping up")
	elif  velocity.x == 600 and velocity.y < 0  and onGround == 2:
		animated_sprite.flip_h = false
		animated_sprite.play("double jump")
	elif  velocity.x == -600 and velocity.y < 0 and onGround == 2 :
		animated_sprite.flip_h = true
		animated_sprite.play("double jump")
	elif  velocity.x == 600 and velocity.y > 0:
		animated_sprite.flip_h = false
		animated_sprite.play("jumping down")
	elif  velocity.x == -600 and velocity.y > 0:
		animated_sprite.flip_h = true
		animated_sprite.play("jumping down")
	elif   velocity.y < 0  and onGround < 2:
		animated_sprite.play("jumping up")
	elif  velocity.y < 0 and onGround == 2 :
		animated_sprite.flip_h = true
		animated_sprite.play("double jump")
	elif   velocity.y > 0 :
		animated_sprite.play("jumping down")
	elif crouched == false:
		animated_sprite.play("idle")

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


func handleDashing():
	if Input.is_action_just_pressed("dash") and dashDirection != 0:
		dash.start_dash(dashLength)
	speed = dashSpeed if dash.is_dashing() else normalSpeed
	if dash.is_dashing():
		dashing = true
		$Standing.disabled = true
		$Crouch.disabled = false
	else:
		if handleAboveCrouching():
			stand()
		else:
			if stuckUnderObject == false:
				stuckUnderObject = true
				crouch()
	if stuckUnderObject and handleAboveCrouching() and !dash.is_dashing():
		stand()
		stuckUnderObject = false
		
func gravityFunc():
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > 1000:
			velocity.y = 1000

func movement():
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if dash.is_dashing():
		velocity.x = dashDirection * speed # Use the stored dash direction
	else:
		if direction:
			velocity.x = direction * speed  # Update the velocity and dash direction based on input
			dashDirection = direction
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			dashDirection = 0  # Reset the dash direction when the player stops moving


func crouch():
	$Standing.disabled = true
	$Crouch.disabled = false
	crouched = true


func stand():
	$Standing.disabled = false
	$Crouch.disabled = true
	crouched = false
	dashing = false
