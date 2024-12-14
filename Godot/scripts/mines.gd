extends Label
# !СКРИПТ ДЛЯ СЧЁТЧИКА МИН!

func _ready():
	text = str(Global.mines)
func _process(_delta):
	text = str(Global.mines)
