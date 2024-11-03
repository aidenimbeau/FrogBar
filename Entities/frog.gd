extends CharacterBody3D

enum DrinkState {NO_DRINK, WANTS_DRINK, HAS_DRINK}

var drink_state: DrinkState = DrinkState.NO_DRINK

var drink_want: Drinks.DrinkType = Drinks.DrinkType.NO_MATCH

@export var can_move: bool = false
var is_moving: bool = false

@export var movement_timer: Timer
@export var talking_timer: Timer
@export var invincibility_timer: Timer

@onready var nav: NavigationAgent3D = %NavigationAgent3D

@onready var rng = RandomNumberGenerator.new()

func _ready() -> void:
	# Randomize drink want (cannot be no match)
	while drink_want == Drinks.DrinkType.NO_MATCH:
		drink_want = Drinks.DrinkType.values().pick_random()
	
	if can_move:
		movement_timer.wait_time = rng.randf_range(1.0, 5.0)
		movement_timer.timeout.connect(start_moving)
		nav_setup.call_deferred()

func nav_setup():
	nav.path_desired_distance = 0.1
	nav.target_desired_distance = 0.1
	
	await get_tree().physics_frame
	
	nav.navigation_finished.connect(stop_moving)

func set_new_target(): 
	var target: Vector3 = Vector3( rng.randf_range(-3.0, 3.0), 0.0, rng.randf_range(-3.0, 3.0))
	nav.set_target_position( target )

func _physics_process(delta: float) -> void:
	
	if not is_moving or invincibility_timer.time_left > 0.0:
		return
	
	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = nav.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * 1.0
	move_and_slide()

func start_talking() -> void:
	pass

func stop_talking() -> void:
	pass

func become_disturbance() -> void:
	pass

func set_drink_state(new_state: DrinkState) -> void:
	drink_state = new_state

func start_moving() -> void:
	is_moving = true
	set_new_target()
	pass

func stop_moving() -> void:
	is_moving = false
	# set new random stay still duration
	movement_timer.wait_time = rng.randf_range(1.0, 5.0)
	# restart stay-still timer
	movement_timer.start()
	pass

func on_pushed() -> void:
	invincibility_timer.start(0.0)
	$CollisionShape3D.disabled = true
	$SpriteOrigin/MainSprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	var camera: Camera3D = get_viewport().get_camera_3d()
	$SpriteOrigin.global_rotation_degrees.y = camera.global_rotation_degrees.y
	$SpriteOrigin.global_rotation_degrees.x = -85.0
	invincibility_timer.timeout.connect(
		func(): 
			$CollisionShape3D.disabled = false
			$SpriteOrigin/MainSprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
			$SpriteOrigin.global_rotation_degrees.x = 0.0
	)
	if drink_state == DrinkState.HAS_DRINK:
		GameManager.remove_score(5.0)
		drink_state = DrinkState.NO_DRINK

func on_interact(tray_drinks: Array[Drinks.DrinkType]) -> Drinks.DrinkType:
	# Check if tray contains drink they want
	# If so, change state and drink want.
	for drink: Drinks.DrinkType in tray_drinks:
		if drink == drink_want:
			set_drink_state(DrinkState.HAS_DRINK)
			return Drinks.DrinkType
	
	# Do the "nuh-uh"
	
	return Drinks.NO_MATCH
