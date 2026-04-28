extends Node

var music_player: AudioStreamPlayer

func _ready():
	music_player = AudioStreamPlayer.new()
	add_child(music_player)

	# Optional: play default music on start
	play_music(preload("res://Assets/Audio/SoftEng_BG1.wav"))

# 🔥 THIS is what you're missing
func play_music(stream: AudioStream):
	if music_player.stream == stream:
		return
	
	music_player.stream = stream
	music_player.play()

var is_muted = false

func toggle_mute():
	is_muted = !is_muted
	music_player.volume_db = -80 if is_muted else 0

func toggle_play():
	is_muted = !is_muted
	music_player.volume_db = 0 if is_muted else -80
