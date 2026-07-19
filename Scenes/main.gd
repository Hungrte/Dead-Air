extends Node3D

@onready var player = $Entities/Player
@onready var enemy = $Entities/MainAI

@export var max_distance = 50

var distance
var hearing
var attenuation
var loudness

@export var sound_strength = 1 #Will be changed soon since I plan to add different sound strengths for certain noises


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Global.radio_state == true:
		listening()

func listening():
	distance = enemy.global_position.distance_to(player.global_position)
	#print(distance)
	attenuation = clamp(1.0 - distance / max_distance, 0.0, 1.0)
	#print(attenuation)
	loudness = attenuation * sound_strength
	#print(loudness)
	Global.loudness = loudness
	#print(Global.loudness)



	
