extends Node2D

onready var bump1 = $bumps/bump1
onready var bump2 = $bumps/bump2
onready var bump3 = $bumps/bump3
onready var bump4 = $bumps/bump4
onready var bump5 = $bumps/bump5
onready var song1 = $songs/song1
onready var song2 = $songs/song2
onready var song3 = $songs/song3
onready var song4 = $songs/song4
onready var song5 = $songs/song5

var audio_index = 0
var cur_audio
var songs
var bumps

func _ready():
	randomize()
	songs = [song1,song2,song3,song4,song5]
	bumps = [bump1,bump2,bump3,bump4,bump5]
	songs.shuffle()
	bumps.shuffle()
func start_radio():
	songs[audio_index].play()
func to_bump():
	audio_index += 1
	if audio_index >= bumps.size():
		shuffle_radio()
	bumps[audio_index].play()
	cur_audio = bumps[audio_index]
func to_song():
	audio_index += 1
	if audio_index >= bumps.size():
		shuffle_radio()
	songs[audio_index].play()
	cur_audio = songs[audio_index]
func pause_radio():
	cur_audio.pause()
func play_radio():
	cur_audio.play()
func shuffle_radio():
	songs.shuffle()
	bumps.shuffle()

#Not elegant, I know but it's a game jam game ¯\_(ツ)_/¯ 
func _on_bump1_finished():
	to_song()
func _on_bump2_finished():
	to_song()
func _on_bump3_finished():
	to_song()
func _on_bump4_finished():
	to_song()
func _on_bump5_finished():
	to_song()
func _on_song1_finished():
	to_bump()
func _on_song2_finished():
	to_bump()
func _on_song3_finished():
	to_bump()
func _on_song4_finished():
	to_bump()
func _on_song5_finished():
	to_bump()
