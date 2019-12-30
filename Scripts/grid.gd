extends Node2D

# Grid Variables
export (int) var width;
export (int) var height;
export (int) var x_start;
export (int) var y_start;
export (int) var offset;

# The piece array
var possible_pieces = [
preload("res://Scenes/blue_piece.tscn"),
preload("res://Scenes/green_piece.tscn"),
preload("res://Scenes/light_green_piece.tscn"),
preload("res://Scenes/orange_piece.tscn"),
preload("res://Scenes/pink_piece.tscn"),
preload("res://Scenes/yellow_piece.tscn")
];

# Current pieces in the scene
var all_pieces = [];

# Touch Variables
var first_touch = Vector2(0, 0);
var final_touch = Vector2(0, 0);
var controlling = false;



# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	all_pieces = make_2d_array()
	spawn_pieces()
	# Replace with function body.

func make_2d_array():
	var array = [];
	for i in width:
		array.append([]);
		for j in height:
			array[i].append(null);
	return array;

func spawn_pieces():
	for i in width:
		for j in height:
			# Choose a random number and store it
			var rand = floor(rand_range(0, possible_pieces.size()));
			var piece = possible_pieces[rand].instance();
			var loops = 0;
			while(match_at(i, j, piece.color) && loops < 100):
				rand = floor(rand_range(0, possible_pieces.size()));
				loops += 1;
				piece = possible_pieces[rand].instance();
			# Instance that piece from the array
			add_child(piece);
			piece.position = grid_to_pixel(i, j);
			all_pieces[i][j] = piece;

func match_at(i, j, color):
	if i > 1:
		if all_pieces[i - 1][j] != null && all_pieces[i - 2][j] != null:
			if all_pieces[i - 1][j].color == color && all_pieces[i - 2][j].color == color:
				return true;
	if j > 1:
		if all_pieces[i][j - 1] != null && all_pieces[i][j - 2] != null:
			if all_pieces[i][j - 1].color == color && all_pieces[i][j - 2].color == color:
				return true;


# Transform grid position to pixel position
func grid_to_pixel(column, row):
	var new_x = x_start + offset * column;
	var new_y = y_start + -offset * row;
	return Vector2(new_x, new_y);

func pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start) / offset);
	var new_y = round((pixel_y - y_start) / -offset);
	return Vector2(new_x, new_y)
	pass;	

func is_in_grid(column, row):
	if column >= 0 && column < width:
		if row >= 0 && row < height:
			return true;
	return false;

func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		first_touch = get_global_mouse_position();
		var grid_position = pixel_to_grid(first_touch.x, first_touch.y);
		if is_in_grid(grid_position.x, grid_position.y):
			controlling = true;
	if Input.is_action_just_released("ui_touch"):
		final_touch = get_global_mouse_position();
		var grid_position = pixel_to_grid(final_touch.x, final_touch.y);
		if is_in_grid(grid_position.x, grid_position.y) && controlling:
			touch_difference(pixel_to_grid(first_touch.x, first_touch.y), grid_position);
			controlling = false;

func swap_pieces(column, row, direction):
	var first_piece = all_pieces[column][row];
	var other_piece = all_pieces[column + direction.x][row + direction.y];
	all_pieces[column][row] = other_piece;
	all_pieces[column + direction.x][row + direction.y] = first_piece;
	first_piece.move(grid_to_pixel(column + direction.x, row + direction.y));
	other_piece.move(grid_to_pixel(column, row));
	find_matches()

func touch_difference(grid_1, grid_2):
	var difference = grid_2 - grid_1;
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(1, 0));
		elif difference.x < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(-1, 0));
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, 1));
		elif difference.y < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, -1));


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	touch_input();

func find_matches():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var current_color = all_pieces[i][j].color
				if i > 0  && i < width - 1:
					if all_pieces[i - 1][j] != null && all_pieces[i + 1][j] != null:
						if all_pieces[i - 1][j].color == current_color && all_pieces[i + 1][j].color == current_color:
							all_pieces[i - 1][j].matched = true;
							all_pieces[i - 1][j].dim()
							all_pieces[i][j].matched = true;
							all_pieces[i][j].dim();
							all_pieces[i + 1][j].matched = true;
							all_pieces[i + 1][j].dim();
				if j > 0  && j < height - 1:
					if all_pieces[i][j - 1] != null && all_pieces[i][j + 1] != null:
						if all_pieces[i][j - 1].color == current_color && all_pieces[i][j + 1].color == current_color:
							all_pieces[i][j - 1].matched = true;
							all_pieces[i][j - 1].dim()
							all_pieces[i][j].matched = true;
							all_pieces[i][j].dim();
							all_pieces[i][j + 1].matched = true;
							all_pieces[i][j + 1].dim();
	pass;