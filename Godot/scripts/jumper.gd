extends Control
# !СКРИПТ ДЛЯ ГЕЙМ-ОВЕРА!

const speed : int = 1
var time : float

func _ready():
	time = 0

func _process(delta):
	time += delta * speed
	rotation = sin(time * 1) * 0.25
