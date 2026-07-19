extends CharacterBody3D

# --------------------------------------------------
# State Variables
# --------------------------------------------------

var dt: float
# Delta

# ---- Movement ----
@export var base_speed := 5.0
# speed of the ai

@export var speed_gain: float = 1.005
@export var speed_loss: float = 1.01
@export var max_speed := 9.0

var current_speed = base_speed
# the Ai's current speed

# ---- Signals ----
@export var suspicion_gain: float = 25.0
# rate of suspicion gain
@export var suspicion_decay: float = 5.0

# rate of suspicion decay
@export var radio_range: int = 100
# range in which the ai hears the radio

@export var max_suspicion: int = 100
# Threshold for suspicion before investigating
@export var sense_cooldown: int
var suspicion := 0.0

var direction: Vector3
var investigate_position: Vector3
# last known position of signal
var last_seen_position: Vector3

var position_tolerance: float = 0.5

var distance_from_player: float
# distance from/to the player
var distance_from_signal: float
# distance from/to the signal
var radio_signal_strength: float
# signal strength of the radio

var radio_state: bool = false
var player_visible: bool = false
var player_in_range: bool
var search_started: bool = false
var can_move: bool = true
var start_stun_timer: bool = true

# ---- Senses ----
enum SenseMode{
	HEARING,
	VISION,
	SWITCHING
}

var sense_mode = SenseMode.HEARING
var next_sense = SenseMode.HEARING
# ---- States ----

enum AIState {
	IDLE,
	SEARCHING,
	CHASING,
	ATTACKING
}
var state = AIState.IDLE

@export var attack_range: int = 3
# range where the player has to be in to be attacked
@export var chase_range: int = 7
# range where the player has to be in to be chased

# ---- Timer ----
@onready var suspicionTime = $Timers/suspicionTime
@onready var search_timer  = $Timers/searchtimer
@onready var chasetimer    = $Timers/chasetimer
@onready var stuntimer     = $Timers/stuntime
@onready var senseTimer    = $Timers/sensetimer

func _ready() -> void:
	pass

# --------------------------------------------------
# Physics Update
# --------------------------------------------------

func _physics_process(delta: float) -> void:
	dt = delta
	update_positions()
	update_senses()
	update_state()
	perform_behavior()
	apply_gravity()


# --------------------------------------------------
# State Behaviors
# --------------------------------------------------


func apply_gravity():
	if not is_on_floor():
		velocity += get_gravity() * dt


func move_to_position(target_positon: Vector3):
	if can_move:
		direction = target_positon - global_position
		
		current_speed = move_toward(current_speed, max_speed, speed_gain * dt)
		velocity = current_speed * direction.normalized()
	
		look_at(target_positon, Vector3.UP)
		
	move_and_slide()


func update_state():
	match state:
		AIState.IDLE:
			update_idle()
		AIState.SEARCHING:
			update_searching()
		AIState.CHASING:
			update_chasing()
		AIState.ATTACKING:
			pass
		

func change_state(new_state):
	if state == new_state:
		return
	print("State:", AIState.keys()[state], "->", AIState.keys()[new_state])
	state = new_state
	
	match state:
		AIState.SEARCHING:
			enter_searching()


func suspicion_meter():
	if radio_state == false:
		suspicion -= suspicion_decay * dt
		suspicion = clamp(suspicion, 0, max_suspicion)
		return
	
	switch_to_senses(SenseMode.HEARING)
	suspicion += suspicion_gain * dt * radio_signal_strength
	suspicion = clamp(suspicion, 0.0, max_suspicion)


func update_positions():
	distance_from_player = global_position.distance_to(Global.global_player)
	distance_from_signal = global_position.distance_to(Global.radio_position)


func investigate_sound():
	move_to_position(investigate_position)
	if global_position.distance_to(investigate_position) < position_tolerance:
		switch_to_senses(SenseMode.VISION)
		look_around()
		if !search_started:
			search_timer.start()
			search_started = true


func idling():
	look_around()


func look_around():
	pass # will be changed once I have models or be changed with simple animations

func chase():
	suspicion = 0
	move_to_position(Global.global_player)
	if distance_from_player < chase_range:
		current_speed = move_toward(current_speed, base_speed, speed_loss * dt)


func attack():
	switch_to_senses(SenseMode.VISION)
	suspicion = 0
	can_move = false
	stunned()


func stunned():
	if start_stun_timer:
		start_stun_timer = false
		stuntimer.start()


func perform_behavior():
	
	match state:
		
		AIState.IDLE:
			idling()
			
		AIState.SEARCHING:
			investigate_sound()
			
		AIState.CHASING:
			chase()
			
		AIState.ATTACKING:
			attack()

# --------------------------------------------------
# UPDATE STATE
# --------------------------------------------------

func update_idle():
	if suspicion >= max_suspicion:
		change_state(AIState.SEARCHING)
		return


func update_searching():
	if player_visible and distance_from_player < attack_range:
		change_state(AIState.ATTACKING)
		return

	if player_visible:
		change_state(AIState.CHASING)
		return

func update_chasing():
	if player_visible and distance_from_player < attack_range:
		change_state(AIState.ATTACKING)
		return
	
	if chasetimer.is_stopped():
		change_state(AIState.SEARCHING)
		return


func update_attacking():
	if distance_from_player < attack_range:
		change_state(AIState.CHASING)
		return
	
	if !player_visible:
		change_state(AIState.SEARCHING)
		return


# --------------------------------------------------
# Signal Detection
# --------------------------------------------------

func update_hearing():
	radio_signal_strength = Global.loudness
	radio_state = Global.radio_state
	
	if radio_state == true:
		if distance_from_signal < radio_range:
			suspicion_meter()
		return
	
	suspicion_meter()


func update_vision():
	if !player_in_range:
		player_visible = false
		return
	
	player_visible = true
	chasetimer.stop()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == 'Player':
		print('Player_detected')
		player_in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == 'Player':
		print('Player_exited')
		player_in_range = false
		chasetimer.start()


func _on_searchtimer_timeout() -> void:
	suspicion = 0
	search_started = false
	

func _on_stuntime_timeout() -> void:
	can_move = true


func _on_sensetimer_timeout() -> void:
	sense_mode = next_sense

# --------------------------------------------------
# Enter States
# --------------------------------------------------

func update_senses():
	match sense_mode:
		SenseMode.HEARING:
			update_hearing()
		SenseMode.VISION:
			update_vision()
		SenseMode.SWITCHING:
			pass


func switch_to_senses(new_sense):
	
	if sense_mode == new_sense:
		return
	
	if sense_mode == SenseMode.SWITCHING:
		return
	
	next_sense = new_sense
	sense_mode = SenseMode.SWITCHING
	senseTimer.start()


func enter_searching():
	investigate_position = Global.radio_position
	current_speed = base_speed
