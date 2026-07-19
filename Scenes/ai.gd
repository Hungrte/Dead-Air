extends CharacterBody3D

# --------------------------------------------------
# State Variables
# --------------------------------------------------

# ---- Movement ----
@export var speed := 5.0
var direction: Vector3
var can_move: bool = true

# ---- Signals ----
var last_heard_position: Vector3
var heard_radio: bool = false
var player_in_range: bool = false
var player_visible: bool = false
var suspicious: bool

# ---- States ----
enum AIState {
	IDLE,
	SEARCHING,
	CHASING,
	ATTACKING
}

var state = AIState.IDLE
var is_listening: bool = false
@export var attack_range: int = 3
@export var chase_range: int = 7

# ---- Timer ----
@export var max_suspicion: int = 10
@export var search_wait_time: float = 5.0
@onready var suspicionTime = $Timers/suspicionTime
@onready var search_timer = $Timers/searchtimer

var searched: bool = false

func _ready() -> void:
	change_state(AIState.IDLE)
	search_timer.wait_time = search_wait_time
	suspicionTime.wait_time = max_suspicion

# --------------------------------------------------
# Physics Update
# --------------------------------------------------

func _physics_process(delta: float) -> void:
	update_hearing()
	check_player_distance()
	
	update_state()
	match state:
		
		AIState.IDLE:
			pass
			# Looking around 
		
		AIState.SEARCHING:
			investigate_sound()
		
		AIState.CHASING:
			chase()
		
		AIState.ATTACKING:
			attack()

	# Add the gravity.
	
	if not is_on_floor():
		velocity += get_gravity() * delta


func start_suspicion_timer():
	if is_listening == false:
		suspicionTime.start()
		heard_radio = false
		is_listening = true

# --------------------------------------------------
# State Behaviors
# --------------------------------------------------


func update_hearing():
	if Global.radio_state:
		last_heard_position = Global.radio_position
	
	if Global.loudness <= 1 and Global.loudness != 0:
		heard_radio = true
	else:
		heard_radio = false
	
	if heard_radio:
		print(suspicionTime.time_left)
		start_suspicion_timer()
	else:
		is_listening = false
		suspicionTime.stop()


func investigate_sound():
	if global_position == last_heard_position:
		can_move = false
	if can_move:
		look_at(last_heard_position, Vector3.UP)
		move_to_target(last_heard_position)


func chase():
	look_at(Global.global_player, Vector3.UP)
	
	move_to_target(Global.global_player)


func attack():
	print('Attacked!!') # will be swapped for some function or code for attacking
	change_state(AIState.IDLE)


func move_to_target(target_direction):
	direction = target_direction - global_position
	velocity = direction.normalized() * speed
		
	move_and_slide()


# --------------------------------------------------
# Signal Detection
# --------------------------------------------------

func update_state():
	match state:
		
		AIState.IDLE:
			if suspicious:
				change_state(AIState.SEARCHING)
				suspicious = false
			# Looking around 
		
		AIState.SEARCHING:
			if player_visible:
				search_timer.stop()
				change_state(AIState.CHASING)
				return
		
		AIState.CHASING:
			if not player_visible:
				change_state(AIState.SEARCHING)
				return
		
		AIState.ATTACKING:
			pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.get_name() == 'Player' and Global.loudness <= 1 and Global.loudness != 0:
		can_move = true
		print('Player Detected!!')
		change_state(AIState.SEARCHING)


func _on_suspicion_time_timeout() -> void:
	suspicious = true



func check_player_distance():
	var distance = global_position.distance_to(Global.global_player)
	player_visible = distance < chase_range

	if distance < attack_range:
		change_state(AIState.ATTACKING)
		return 'Attack'



func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.get_name() == 'Player':
		print('Player Exited!!')
		


func change_state(new_state):
	print("State:", state, "->", new_state)
	if state == new_state:
		return
	
	state = new_state
	
	match state:
		
		AIState.SEARCHING:
			search_timer.start()
		
		AIState.CHASING:
			search_timer.stop()
		
		AIState.ATTACKING:
			search_timer.stop()


func _on_searchtimer_timeout() -> void:
	can_move = true
	search_timer.stop()
	change_state(AIState.IDLE)



	
