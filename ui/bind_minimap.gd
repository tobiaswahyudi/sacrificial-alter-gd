@tool
extends Control

@export var margin: float;

@export var box_size: float;
@export var box_line_weight: float;

@export var font_size: float;

@export var cable_line_weight: float;

var font: Font = ThemeDB.fallback_font;

###################
# Draw state            

class StringPair:
	var first: String
	var second: String
	func _init(p_first: String, p_second: String):
		first = p_first
		second = p_second

var all_names: Array[String]
var draw_positions: Dictionary[String, Vector2i] = {}
var connections: Array[StringPair] = []

###################



# When the bind is changed at all, the UI needs to rediscover all connected modules and sort them in order.
func regenerate_nodes():
	draw_positions = {};
	connections = [];

	for idx in range(len(Bindings.BINDS)):
		var bind_name = Bindings.BINDS[idx]
		draw_positions[bind_name] = Vector2i(idx + 1, 0)
		all_names.append(bind_name)

	for idx in range(len(Bindings.INTENTS)):
		var intent_name = Bindings.INTENTS[idx]
		draw_positions[intent_name] = Vector2i(idx + 1, 2)
		all_names.append(intent_name)

	# For now there's no modules, so all connections come from keybinds. That's nice and easy
	for bind_name in Bindings.BINDS:
		var bind_ui = Bindings.keybind_nodes[bind_name]
		for output_node in bind_ui.outputs:
			connections.append(StringPair.new(bind_name, output_node.name))

func _ready() -> void:
	regenerate_nodes()
	# should also connect a signal on the bindings singleton to regenerate_nodes

func _process(delta: float) -> void:
	queue_redraw()

func calc_col_left(i: float) -> float:
	return margin -i * (box_size + margin)

func calc_col_middle(i: float) -> float:
	return margin -i * (box_size + margin) + (box_size * 0.5)

func calc_row_top(i: float) -> float:
	return i * (box_size + margin)

func calc_row_bottom(i: float) -> float:
	return calc_row_top(i) + box_size

func _draw() -> void:
	# draw_line(Vector2(-100, 100), Vector2(-300, 400))
	for n_name in all_names:
		var pos = draw_positions[n_name]
		
		var color = Color.PURPLE
		if Bindings.nodes[n_name].is_firing():
			color = Color.AQUA

		draw_rect(Rect2(Vector2(calc_col_left(pos.x), calc_row_top(pos.y)), Vector2(box_size, box_size)), Color.WHITE, true);
		draw_rect(Rect2(Vector2(calc_col_left(pos.x), calc_row_top(pos.y)), Vector2(box_size, box_size)), color, false, box_line_weight);
		draw_multiline_string(font, Vector2(calc_col_left(pos.x), calc_row_top(pos.y + 0.3)), Bindings.STRINGS[n_name], 1, box_size, font_size, -1, color);

	for conn_pair in connections:
		var src = conn_pair.first
		var dst = conn_pair.second

		var src_pos = draw_positions[src]
		var dst_pos = draw_positions[dst]
		var src_bottom = Vector2(calc_col_middle(src_pos.x), calc_row_bottom(src_pos.y))
		var dst_top = Vector2(calc_col_middle(dst_pos.x), calc_row_top(dst_pos.y))

		var color = Color.PURPLE
		if Bindings.nodes[src].is_firing():
			color = Color.AQUA

		draw_line(src_bottom, dst_top, color, cable_line_weight)
