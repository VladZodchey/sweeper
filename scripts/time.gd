extends Label
# !СКРИПТ ДЛЯ ТАЙМЕРА!

func _process(_delta):
	text = str(int(Global.time))
