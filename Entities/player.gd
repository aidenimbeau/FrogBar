extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var tray_contents: Array[Drinks.DrinkType] = []

@export var rotation_speed = 2.0

var can_push: bool = true

func _input(event):
	if event.is_action_pressed("interact"):
		interact()

func _process(delta: float) -> void:
	
	if Input.is_action_pressed("tray_left") and Input.is_action_pressed("tray_right") and can_push:
		push()
	
	if Input.is_action_just_released("tray_left") || Input.is_action_just_released("tray_right"):
		can_push = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("ui_accept"):
		GameManager.add_score(5.00)
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(0, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	rotate_y( -input_dir.x * rotation_speed * delta )

	move_and_slide()

func push():
	# Check what frogs are in front in area2D, call their on_pushed()
	can_push = false
	
	for body in $PushArea.get_overlapping_bodies():
		if body.has_method("on_pushed"):
			body.on_pushed()
	
	pass

func interact():
	# What am I interacting with?
	print("Interact!")
	pass
