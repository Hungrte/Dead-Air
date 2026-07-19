extends Control

var full_bar = '■■■■■■■■■■'
var empty_bar = '□□□□□□□□□□'
var signal_strength

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	radio_status()
	bar_state()
	

func radio_status():
	if Global.radio_state:
		$Label.text = "[Radio: On]"
	else:
		$Label.text = "[Radio: Off]"


func bar_state():
	if !Global.radio_state:
		$Label2.text = "[Signal: " + empty_bar +  "]"
	else:
		signal_strength = Global.loudness
		signal_strength = round(remap(signal_strength, 0.0, 1.0, 0.0, 10.0))
		$Label2.text = "[Signal: " + full_bar.substr(0, signal_strength) + '' + empty_bar.substr(signal_strength, 10 - signal_strength) + ']'
