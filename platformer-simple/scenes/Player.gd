extends KinematicBody2D

var hspeed = 128 # px / s^2
var vspeed = 32
var gravity = 128 # px / s^2
var hmax = 64 # px / s
var hdamping := 0.2 # %

var velocity := Vector2.ZERO

var jump_height = 40 # px

var y_origin: float
var is_grounded := false

# Called when the node enters the scene tree for the first time.
func _ready():
	y_origin = position.y

func _physics_process(delta):
	
	var is_move_pressed = false
	
	if Input.is_action_pressed("move_right"):
		is_move_pressed = true
				
		if Vector2.RIGHT.dot(velocity) < 0: 
			velocity.x *= 0.5
		
		velocity += hspeed * delta * Vector2.RIGHT

	if Input.is_action_pressed("move_left"):
		is_move_pressed = true
		
		if Vector2.LEFT.dot(velocity) < 0: 
			velocity.x *= 0.5
		
		velocity += hspeed * delta * Vector2.LEFT
		
	if Input.is_action_just_pressed("jump"):
		velocity.y = -1 * get_jump_impulse()
		print_debug(delta, ',', velocity)
	
	velocity += gravity * delta * Vector2.DOWN
	
	velocity.x = clamp(velocity.x, -1 * hmax, hmax)
	
	# horizontal friction
	if !is_move_pressed && is_grounded: 
		velocity.x *= 1.0 - hdamping
	
	# account for terrain collisions
	velocity = move_and_slide(velocity)
	
	position += velocity * delta
	
	if velocity.dot(Vector2.DOWN) > 0: 
		is_grounded = false
	
	if !is_grounded:
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			
			if 1.0 - Vector2.UP.dot(collision.normal) < 0.1: 
				print("I collided with ", collision.collider.name)
				is_grounded = true
		
		# show the height of the jump at max of its arc
		if !is_grounded && abs(velocity.y) <= 1: 
			print_debug(position.y - y_origin)
	
func get_jump_impulse():
	# adapted from unity
	# acceleration = (targetVelocity - current_velocity) / Time.deltaTime

	y_origin = position.y
	is_grounded = false

	var h := float(jump_height)
	var g := float(gravity)
	
	var t_flight := sqrt(2 * h / g)

	# there's something I'm not understanding--shouldn't need magic number
	var v0: float = h / t_flight + 0.2175 * g * t_flight # 0.25 was 0.5 previously; still not sure why off by factor of 2
	
	return v0
