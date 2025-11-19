extends Node2D

##
#  Transform Tetris Game Logic
#
#  This script implements a variant of Tetris where players manipulate
#  falling tetrominoes using explicit geometric transformations. Pieces do
#  not fall automatically until dropped; instead, players can translate,
#  rotate and reflect them before committing. A ghost preview illustrates
#  where the piece will land given its current transformation state. The
#  game supports both timed and untimed play modes. In timed mode a
#  countdown forces the piece to drop when time expires. In untimed mode
#  players have unlimited planning time but each transformation incurs a
#  small score penalty.

const BOARD_WIDTH  : int = 10		# standard Tetris width
const BOARD_HEIGHT : int = 20		# standard Tetris height
const CELL_SIZE	: int = 24		# pixel size of each grid cell

# Definition of tetromino shapes. Each entry consists of a name, a color
# and a list of Vector2 offsets relative to the piece's pivot. The pivot
# for all shapes is the origin (0,0); rotations and reflections are
# performed around this point.
const SHAPES = [
	{
		"name": "I",
		"color": Color(0.0, 1.0, 1.0),
		"cells": [Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(2, 0)]
	},
	{
		"name": "O",
		"color": Color(1.0, 1.0, 0.0),
		"cells": [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)]
	},
	{
		"name": "T",
		"color": Color(0.6, 0.0, 0.8),
		"cells": [Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(0, 1)]
	},
	{
		"name": "S",
		"color": Color(0.0, 1.0, 0.0),
		"cells": [Vector2(-1, 1), Vector2(0, 1), Vector2(0, 0), Vector2(1, 0)]
	},
	{
		"name": "Z",
		"color": Color(1.0, 0.0, 0.0),
		"cells": [Vector2(-1, 0), Vector2(0, 0), Vector2(0, 1), Vector2(1, 1)]
	},
	{
		"name": "J",
		"color": Color(0.0, 0.0, 1.0),
		"cells": [Vector2(-1, 0), Vector2(-1, 1), Vector2(0, 0), Vector2(1, 0)]
	},
	{
		"name": "L",
		"color": Color(1.0, 0.5, 0.0),
		"cells": [Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(1, 1)]
	}
]

# Game state variables
var board : Array = []						 # 2‑D array storing Color or null for each cell
var current_shape_data : Dictionary			# currently falling tetromino definition
var current_cells : Array = []				# copy of current_shape_data.cells (Vector2 list)
var current_offset : Vector2 = Vector2.ZERO	# integer offset into the grid
var ghost_cells : Array = []				  # positions of the ghost preview (Vector2 list)
var transform_count : int = 0				 # number of transformations performed on the current piece
var score : int = 0						   # player's score
var timed_mode : bool = true				  # whether the game is in timed mode
# UI elements
@onready var ui_panel : Panel = $Panel
@onready var ui_vbox : VBoxContainer = $Panel/VBoxContainer
var ui_layer : CanvasLayer					# container for UI controls
var score_label : Label					   # displays current score
var timer_label : Label					   # displays current score
var mode_checkbox : CheckBox				  # toggles timed/untimed mode
var _button_y : float = 100.0				 # helper for stacking buttons vertically
var panel_size : int = 10

var piece_timer : Timer					   # timer used for timed mode

func _ready() -> void:
	randomize()
	_init_board()
	# Grab reference to the Timer node defined in the scene.  The timer is
	# configured as one‑shot and will not start on its own.
	piece_timer = $PieceTimer
	piece_timer.one_shot = true
	piece_timer.autostart = false
	piece_timer.connect("timeout", Callable(self, "_on_piece_timer_timeout"))
	# Set up the user interface (score, mode toggle and transformation buttons)
	_create_ui()
	# Spawn the first piece into the empty board
	_spawn_piece()
	ui_vbox.position += Vector2(10,10)

func _resize_panel():
	print(ui_vbox.size)
	ui_panel.size = ui_vbox.size + Vector2(20, 20)
	print(ui_panel.size)
	
func _init_board() -> void:
	# Initialize the board as an array of height rows, each containing
	# BOARD_WIDTH entries.  A null entry signifies an empty cell.
	board.clear()
	board.resize(BOARD_HEIGHT)
	for y in range(BOARD_HEIGHT):
		board[y] = []
		board[y].resize(BOARD_WIDTH)
		for x in range(BOARD_WIDTH):
			board[y][x] = null

func _create_ui() -> void:
#	ui_layer = CanvasLayer.new()
#	add_child(ui_layer)

	# Score label
	score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.text = "Score: 0"
	# Position the label to the right of the game board
	#score_label.position = Vector2(BOARD_WIDTH * CELL_SIZE + 20, 20)
#	ui_layer
	panel_size += 30
	
	ui_vbox.add_child(score_label)
	timer_label = Label.new()
	timer_label.name = "TimerLabel"
	timer_label.text = "Time: 0:00"
	#timer_label.position = Vector2(BOARD_WIDTH * CELL_SIZE + 20, 50)
#	ui_layer.add_child(timer_label)
	ui_vbox.add_child(timer_label)
	panel_size += 30
	
	# Mode toggle (timed/untimed)
	mode_checkbox = CheckBox.new()
	mode_checkbox.text = "Timed Mode"
	mode_checkbox.position = Vector2(BOARD_WIDTH * CELL_SIZE + 20, 60)
	mode_checkbox.button_pressed = true
	mode_checkbox.connect("toggled", Callable(self, "_on_mode_toggled"))
	ui_vbox.add_child(mode_checkbox)
	panel_size += 30

	# Reset the button y offset for subsequent buttons
	_button_y = 100.0
	# Helper to add a button with the given label and callback name

	# Create transformation buttons
	_add_button("T(-1,0)", "_on_move_left")
	_add_button("T(1,0)", "_on_move_right")
	_add_button("T(0,1)", "_on_move_down")
	_add_button("R90°", "_on_rotate")
	_add_button("Reflect H", "_on_reflect_horizontal")
	_add_button("Reflect V", "_on_reflect_vertical")
	_add_button("Drop", "_on_drop")

func _add_button(label_text: String, callback_name: String) -> void:
	var btn := Button.new()
	btn.text = label_text
	#btn.position = Vector2(BOARD_WIDTH * CELL_SIZE + 20, _button_y)
	btn.size = Vector2(120, 32)
	btn.connect("pressed", Callable(self, callback_name))
	#ui_layer.add_child(btn)
	ui_vbox.add_child(btn)
	_button_y += 40.0
	panel_size += 30
	
func _spawn_piece() -> void:
	# Select a random shape definition and duplicate its cell list so we
	# can modify it independently.  The piece spawns centered horizontally
	# above the visible grid (y offset of -1) to allow room for rotations.
	current_shape_data = SHAPES[randi() % SHAPES.size()]
	current_cells = []
	for cell in current_shape_data["cells"]:
		current_cells.append(cell)
	current_offset = Vector2(int(BOARD_WIDTH / 2) - 1, -1)
	transform_count = 0
	# Start the timer for timed mode; stop it otherwise
	if timed_mode:
		piece_timer.start(10.0)
	else:
		piece_timer.stop()
		timer_label.visible = true
		timer_label.visible = false
	_update_ghost()

func _valid_position(cells: Array, offset: Vector2) -> bool:
	# Checks whether the given shape cells placed at offset are within the
	# boundaries of the board and do not collide with existing blocks.  Cells
	# above the visible area (y < 0) are permitted.
	for cell in cells:
		var x := int(cell.x + offset.x)
		var y := int(cell.y + offset.y)
		# Check horizontal bounds
		if x < 0 or x >= BOARD_WIDTH:
			return false
		# Check vertical bounds
		if y >= BOARD_HEIGHT:
			return false
		# Ignore cells above the board when checking collision
		if y >= 0 and board[y][x] != null:
			return false
	return true

func _apply_translation(dx: int, dy: int) -> void:
	# Applies a translation to the current piece if the resulting position is
	# valid.  In untimed mode a translation counts toward the transformation
	# penalty.  Invalid moves are silently ignored.
	var new_offset := current_offset + Vector2(dx, dy)
	if _valid_position(current_cells, new_offset):
		current_offset = new_offset
		transform_count += 1
		_update_ghost()

func _apply_rotation() -> void:
	# Rotates the current piece 90 degrees clockwise around its pivot.  The
	# rotation is applied only if the new orientation fits within the board
	# without colliding.  Each successful rotation counts as a transformation.
	var rotated := []
	for cell in current_cells:
		# 90° clockwise rotation: (x, y) -> (y, -x)
		rotated.append(Vector2(cell.y, -cell.x))
	if _valid_position(rotated, current_offset):
		current_cells = rotated
		transform_count += 1
		_update_ghost()

func _apply_reflection(vertical: bool) -> void:
	# Reflects the current piece across its own local axis.  When vertical
	# is true the piece is mirrored left/right; when false it is mirrored
	# top/bottom.  Validity is checked before committing the change.
	var reflected := []
	for cell in current_cells:
		if vertical:
			# Mirror across the piece's vertical axis: x -> -x
			reflected.append(Vector2(-cell.x, cell.y))
		else:
			# Mirror across the horizontal axis: y -> -y
			reflected.append(Vector2(cell.x, -cell.y))
	if _valid_position(reflected, current_offset):
		current_cells = reflected
		transform_count += 1
		_update_ghost()

func _update_ghost() -> void:
	# Computes the ghost preview positions by simulating a drop from the
	# current position.  The ghost stops one cell above the first
	# collision or the bottom of the board.  The board is redrawn to
	# incorporate the new ghost.
	var drop_offset := current_offset
	while _valid_position(current_cells, drop_offset + Vector2(0, 1)):
		drop_offset.y += 1
	ghost_cells.clear()
	for cell in current_cells:
		ghost_cells.append(cell + drop_offset)
	queue_redraw()

func _clear_lines() -> int:
	# Checks for and removes any fully filled rows in the board.  Returns
	# the number of lines cleared.  Cleared lines increase the player's
	# score quadratically (1 line -> 100, 2 lines -> 300, 3 lines -> 500,
	# 4 lines -> 800).  This function does not update the score or UI; the
	# caller should handle scoring and redrawing.
	var lines_cleared := 0
	# Iterate from bottom to top so that removing rows does not skip any
	for y in range(BOARD_HEIGHT - 1, -1, -1):
		var full := true
		for x in range(BOARD_WIDTH):
			if board[y][x] == null:
				full = false
				break
		if full:
			lines_cleared += 1
			board.remove_at(y)
			var new_row := []
			new_row.resize(BOARD_WIDTH)
			for i in range(BOARD_WIDTH):
				new_row[i] = null
			board.insert(0, new_row)
	return lines_cleared

func _drop_piece() -> void:
	# Commits the current piece to the board by dropping it to its ghost
	# position.  Lines are cleared and scoring applied.  The next piece is
	# spawned immediately afterwards.  Called either when the player
	# presses Drop or when the timer runs out in timed mode.
	# Stop the timer to avoid an extra timeout
	piece_timer.stop()
	# Calculate the drop offset by simulating downward movement
	var drop_offset := current_offset
	while _valid_position(current_cells, drop_offset + Vector2(0, 1)):
		drop_offset.y += 1
	# Place the piece on the board
	for cell in current_cells:
		var x := int(cell.x + drop_offset.x)
		var y := int(cell.y + drop_offset.y)
		if y >= 0 and y < BOARD_HEIGHT and x >= 0 and x < BOARD_WIDTH:
			board[y][x] = current_shape_data["color"]
	# Scoring
	var lines := _clear_lines()
	if lines > 0:
		# Standard Tetris scoring: n lines yields (n^2) * 100
		score += int(pow(lines, 2)) * 100
	# Apply transformation penalty in untimed mode regardless of line clears
	if not timed_mode:
		score -= transform_count
		if score < 0:
			score = 0
	_update_score_label()
	# Spawn next piece
	_spawn_piece()

func _update_score_label() -> void:
	# Updates the text displayed in the score label.
	if score_label:
		score_label.text = "Score: %d" % score

func _on_piece_timer_timeout() -> void:
	# Called when the piece timer expires in timed mode.  The current piece
	# automatically drops straight down from its current position.
	_drop_piece()

func _on_mode_toggled(pressed: bool) -> void:
	# Toggle between timed and untimed modes.  Switching modes during a
	# piece does not retroactively apply or remove the time penalty; the
	# timer will start or stop for the next piece.  The checkbox will
	# remain in sync with the internal flag.
	timed_mode = pressed
	# If switching to timed mode and a piece is active, start the timer
	if timed_mode:
		# Restart timer with fresh countdown only if it is not already running
		if not piece_timer.is_stopped():
			# Already running; let it continue
			pass
		else:
			piece_timer.start(10.0)
		timer_label.visible = true
	else:
		# Stop timer when switching to untimed mode
		timer_label.visible = false
		piece_timer.stop()
	_resize_panel()
	

	
func _on_move_left() -> void:
	_apply_translation(-1, 0)

func _on_move_right() -> void:
	_apply_translation(1, 0)

func _on_move_down() -> void:
	_apply_translation(0, 1)

func _on_rotate() -> void:
	_apply_rotation()

func _on_reflect_horizontal() -> void:
	_apply_reflection(false)

func _on_reflect_vertical() -> void:
	_apply_reflection(true)

func _on_drop() -> void:
	_drop_piece()

func _draw() -> void:
	# Draw the grid, placed blocks, the ghost preview and the current piece.
	# Clear background by drawing a rectangle over the board area
	draw_rect(Rect2(Vector2.ZERO, Vector2(BOARD_WIDTH * CELL_SIZE, BOARD_HEIGHT * CELL_SIZE)), Color(0.05, 0.05, 0.05))
	# Draw grid lines and filled cells
	for y in range(BOARD_HEIGHT):
		for x in range(BOARD_WIDTH):
			var pos := Vector2(x, y) * CELL_SIZE
			# Draw cell border
			draw_rect(Rect2(pos, Vector2(CELL_SIZE, CELL_SIZE)), Color(0.2, 0.2, 0.2), false)
			# Draw filled cell if present
			var cell_color = board[y][x]
			if cell_color != null:
				draw_rect(Rect2(pos, Vector2(CELL_SIZE, CELL_SIZE)), cell_color)
	# Draw ghost piece with translucency
	if current_shape_data:
		var ghost_color = current_shape_data["color"] * Color(1.0, 1.0, 1.0, 0.3)
		for cell in ghost_cells:
			var gx := int(cell.x)
			var gy := int(cell.y)
			if gy >= 0:
				var gpos := Vector2(gx, gy) * CELL_SIZE
				draw_rect(Rect2(gpos, Vector2(CELL_SIZE, CELL_SIZE)), ghost_color)
		# Draw the current piece at its current offset
		for cell in current_cells:
			var px := int(cell.x + current_offset.x)
			var py := int(cell.y + current_offset.y)
			if py >= 0:
				var ppos := Vector2(px, py) * CELL_SIZE
				draw_rect(Rect2(ppos, Vector2(CELL_SIZE, CELL_SIZE)), current_shape_data["color"])


func _on_v_box_container_resized() -> void:
	_resize_panel()
