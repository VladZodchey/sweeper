extends TileMap
# !СКРИПТ ДЛЯ ДОСКИ!

# Кол-во колонок и рядов + размер тайла
const ROWS : int = 14
const COLS : int = 15
const CELL_SIZE : int = 50

# Айди тайлов
var tile_id : int = 0

var running : bool = 1
var started : bool = 0

# Сигналы
signal died
signal opened
signal flagged
signal won

# Номера слоёв
var mine_layer : int = 0
var number_layer : int = 1
var grass_layer : int = 2
var flag_layer : int = 3
var hover_layer : int = 4

# Номера атласа
var mine_atlas := Vector2i(4, 0)
var hover_atlas := Vector2i(6, 0)
var flag_atlas := Vector2i(5, 0)
var number_atlas : Array = generate_num_atlas()

# Массивы
var mine_coords := []

# Генерит коорды чисел в атласе потому-что вручную вписывать для лохов
func generate_num_atlas():
	var a := []
	for i in range(8):
		a.append(Vector2i(i, 1))
	return a

# void Start() из юнити
func _ready():
	clear()
	mine_coords.clear()
	cover_grass()
	running = 1

# Заполняет поле минами	
func populate_mines(except):
	for i in range(Global.max_mines):
		var mine_pos = Vector2i(randi_range(0, COLS-1), randi_range(0, ROWS-1))
		while mine_coords.has(mine_pos) or (abs(mine_pos.x - except.x) < 2 and abs(mine_pos.y - except.y) < 2):
			mine_pos = Vector2i(randi_range(0, COLS-1), randi_range(0, ROWS-1))
		mine_coords.append(mine_pos)
		# Спавн мины
		set_cell(mine_layer, mine_pos, tile_id, mine_atlas)

# Ставит цифры рядом с минами
func generate_numbers():
	for i in get_empty_cells():
		var mine_count : int = 0
		for j in get_surrounding(i):
			if is_mine(j):
				mine_count += 1
		if mine_count > 0:
			set_cell(number_layer, i, tile_id, number_atlas[mine_count - 1])
func get_empty_cells():
	var empty_cells := []
	for y in range(ROWS):
		for x in range(COLS):
			if not is_mine(Vector2i(x, y)):
				empty_cells.append(Vector2i(x, y))
	return empty_cells
# Возвращает массив клеток вокруг введённой
func get_surrounding(centre):
	var surrounding_cells := []
	var target_cell
	for y in range(3):
		for x in range(3):
			target_cell = centre + Vector2i(x - 1, y - 1)
			if target_cell != centre:
				if (target_cell.x >= 0 and target_cell.x <= COLS - 1 and target_cell.y >= 0 and target_cell.y <= ROWS - 1):
					surrounding_cells.append(target_cell)
	return surrounding_cells

# Накрывает карту травой
func cover_grass():
	for y in range(ROWS):
		for x in range(COLS):
			set_cell(grass_layer, Vector2i(x, y), tile_id, Vector2i(3 - ((x + y) % 2), 0))

# if Input.(...) из Юнити
func _input(event):
	if running:
		if event is InputEventMouseButton:
			if event.position.y < ROWS * CELL_SIZE:
				var map_position = local_to_map(event.position)
				if not started:
					Global.stop = false
					populate_mines(map_position)
					generate_numbers()
					started = true
				if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
					if not is_flag(map_position):
						if is_mine(map_position):
							game_over()
						else:
							process_lmb(map_position)
				elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
					process_rmb(map_position)
# Обработка пкм (установка флажков)
func process_rmb(pos):
	if is_grass(pos):
		if is_flag(pos):
			erase_cell(flag_layer, pos)
			Global.mines += 1
		else:
			set_cell(flag_layer, pos, tile_id, flag_atlas)
			Global.mines -= 1
		flagged.emit()
	var all_revealed := true
	for cell in get_used_cells(mine_layer):
		if not is_flag(cell):
			all_revealed = false
	for i in get_empty_cells():
		if is_grass(i):
			all_revealed = false
	if all_revealed:
		won.emit()
		running = false
# Обработка лкм (подкоп клеток)
func process_lmb(pos):
	var revealed := []
	var to_reveal := [pos]
	while not to_reveal.is_empty():
		erase_cell(grass_layer, to_reveal[0])
		if is_flag(to_reveal[0]):
			Global.mines += 1
			erase_cell(flag_layer, to_reveal[0])
		revealed.append(to_reveal[0])
		if not is_number(to_reveal[0]):
			to_reveal = reveal_cells(to_reveal, revealed)
		to_reveal.erase(to_reveal[0])
	var all_revealed := true
	for cell in get_used_cells(mine_layer):
		if not is_flag(cell):
			all_revealed = false
	for i in get_empty_cells():
		if is_grass(i):
			all_revealed = false
	if all_revealed:
		won.emit()
		running = false
	opened.emit()
func reveal_cells(to_reveal, revealed):
	for i in get_surrounding(to_reveal[0]):
		if not revealed.has(i):
			if not to_reveal.has(i):
				to_reveal.append(i)
	return(to_reveal)
# void Update() из юнити
func _process(_delta):
	var mouse_pos := local_to_map(get_local_mouse_position())
	clear_layer(hover_layer)
	if running:
		if is_grass(mouse_pos):
			set_cell(hover_layer, mouse_pos, tile_id, hover_atlas)
		else:
			if is_number(mouse_pos):
				set_cell(hover_layer, mouse_pos, tile_id, hover_atlas)
# Процессы по проигрышу
func game_over():
	died.emit()
	running = 0
	Global.stop = true
	for y in range(ROWS):
		for x in range(COLS):
			if is_mine(Vector2i(x, y)):
				erase_cell(grass_layer, Vector2i(x, y))

# Проверки по тайлам
func is_mine(pos):
	return get_cell_source_id(mine_layer, pos) != -1
func is_grass(pos):
	return get_cell_source_id(grass_layer, pos) != -1
func is_number(pos):
	return get_cell_source_id(number_layer, pos) != -1
func is_flag(pos):
	return get_cell_source_id(flag_layer, pos) != -1
