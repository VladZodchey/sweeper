extends TileMap

# Grid vars
const ROWS : int = 14
const COLS : int = 15
const CELL_SIZE : int = 50

# Tilemap vars
var tile_id : int = 0

# Layer vars
var mine_layer : int = 0
var number_layer : int = 1
var grass_layer : int = 2
var flag_layer : int = 3
var hover_layer : int = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
