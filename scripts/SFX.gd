extends AudioStreamPlayer
# !СКРИПТ ДЛЯ ЗВУКОВ!

const explosion : AudioStreamWAV = preload("res://assets/Explosion.wav")
const won : AudioStreamWAV = preload("res://assets/Win.wav")

const blip1 : AudioStreamWAV = preload("res://assets/Blip1.wav")
const blip2 : AudioStreamWAV = preload("res://assets/Blip2.wav")
const blip3 : AudioStreamWAV = preload("res://assets/Blip3.wav")

const select : AudioStreamWAV = preload("res://assets/Select.wav")

const flag : AudioStreamWAV = preload("res://assets/Flag.wav")

func _on_died():
	stream = explosion
	play()


func _on_opened():
	var sound_id = randi_range(1, 3)
	match sound_id:
		1:
			stream = blip1
			play()
		2:
			stream = blip2
			play()
		3:
			stream = blip3
			play()


func _on_flagged():
	stream = flag
	play()
	
func _ready():
	if Global.initialized:
		stream = select
		play()
	Global.initialized = true


func _on_won():
	stream = won
	play()
