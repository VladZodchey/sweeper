extends Node
# !ГЛОБАЛЬНЫЕ НАСТРОЙКИ!

const max_mines = 1
var mines = 20
var time = 0
var stop : bool = true
var initialized = false

func _ready():
	time = 0
	stop = true
	mines = max_mines
	
func _process(delta):
	if not stop and time < 999.0:
		time += delta
