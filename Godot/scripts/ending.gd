extends CanvasLayer
# !РЕЛЕ ДЛЯ СИГНАЛОВ!

signal pressed

func _on_button_pressed():
	pressed.emit()
	Global.mines = Global.max_mines
	Global.time = 0
	get_tree().reload_current_scene()


func _on_died():
	get_node("gameover").text = "GAME OVER!"
	get_node("gameover").visible = true
	
func _ready():
	get_node("gameover").visible = false

func _on_won():
	get_node("gameover").text = "POBEDA!"
	get_node("gameover").visible = true
