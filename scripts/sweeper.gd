extends TileMap
# !СКРИПТ ДЛЯ ДОСКИ!

# Кол-во колонок и рядов + размер тайла
const ROWS : int = 14
const COLS : int = 15
const CELL_SIZE : int = 50

# Айди тайлов
var tile_id : int = 0

var running : bool = 1

# Сигналы
signal died
signal opened
signal flagged

# Номера слоёв
var mine_layer : int = 0
var number_layer : int = 1
var grass_layer : int = 2
var flag_layer : int = 3
var hover_layer : int = 4

# Номера атласа
var mine_atlas := Vector2i(4, 0)
var number_atlas : Array = generate_num_atlas()
var hover_atlas := Vector2i(6, 0)
var flag_atlas := Vector2i(5, 0)

# Массивы
var mine_coords := []

func generate_num_atlas():
	var a := []
	for i in range(8):
		a.append(Vector2i(i, 1))
	return a

# void Start() из юнити
func _ready():
	new_game()

# Создаёт поле
func new_game():
	clear()
	mine_coords.clear()
	populate_mines()
	generate_numbers()
	cover_grass()
	running = 1

# Заполняет поле минами	
func populate_mines():
	for i in range(get_parent().TOTAL_MINES):
		var mine_pos = Vector2i(randi_range(0, COLS-1), randi_range(0, ROWS-1))
		while mine_coords.has(mine_pos):
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

func _input(event):
	if running:
		if event is InputEventMouseButton:
			if event.position.y < ROWS * CELL_SIZE:
				var map_position = local_to_map(event.position)
				if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
					if not is_flag(map_position):
						if is_mine(map_position):
							game_over()
						else:
							process_lmb(map_position)
				elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
					process_rmb(map_position)
func process_rmb(pos):
	if is_grass(pos):
		if is_flag(pos):
			erase_cell(flag_layer, pos)
		else:
			set_cell(flag_layer, pos, tile_id, flag_atlas)
		flagged.emit()
func process_lmb(pos):
	var revealed := []
	var to_reveal := [pos]
	while not to_reveal.is_empty():
		erase_cell(grass_layer, to_reveal[0])
		erase_cell(flag_layer, to_reveal[0])
		revealed.append(to_reveal[0])
		if not is_number(to_reveal[0]):
			to_reveal = reveal_cells(to_reveal, revealed)
		to_reveal.erase(to_reveal[0])
	opened.emit()
func reveal_cells(to_reveal, revealed):
	for i in get_surrounding(to_reveal[0]):
		if not revealed.has(i):
			if not to_reveal.has(i):
				to_reveal.append(i)
	return(to_reveal)
# void Update() из юнити
func _process(delta):
	highlight_cell()
func highlight_cell():
	var mouse_pos := local_to_map(get_local_mouse_position())
	clear_layer(hover_layer)
	if is_grass(mouse_pos):
		set_cell(hover_layer, mouse_pos, tile_id, hover_atlas)
	else:
		if is_number(mouse_pos):
			set_cell(hover_layer, mouse_pos, tile_id, hover_atlas)
func game_over():
	died.emit()
	print("Game is over!")
	running = 0
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
