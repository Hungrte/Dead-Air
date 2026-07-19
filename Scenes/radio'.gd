extends Node3D

@export_group("Input Actions")
## Name of input action to toggle on/off radio
@export var toggle : String = "toggle_radio"


var show_radio := false
var loudness

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	Global.radio_position = global_position
	loudness = Global.loudness
	if Global.radio_state == true:
		sound_db()

	radiotoggle()
	


func sound_db(): #DOESNT WORK I DONT KNOW HOW TO ADJUST SOUND 
	var db = remap(loudness, 0.0, 1.0, 0.0, 50.0)
	$Static.volume_db = db
	#print($Static.volume_db)

func radiotoggle():
	if Input.is_action_just_pressed("show_radio"):
			show_radio = !show_radio
			visible = show_radio
	
	if Input.is_action_just_pressed("toggle_radio") and visible == true:
		Global.radio_state = !Global.radio_state  # Flip true <-> false
		
		
		if Global.radio_state:
			print("on")
			$Static.playing = true
		else:
			print("off")
			Global.loudness = 0
			$Static.playing = false
