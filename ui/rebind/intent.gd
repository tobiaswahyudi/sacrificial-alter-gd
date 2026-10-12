@tool
extends TextureRect

class_name IntentUI

@export var check_when_run: bool = true;
@export_group("Display")
@export_multiline var display_text: String;

@export_group("Cables")
@export var cables_count: int = 3;

@export var cable_start_arc_radius: float;
@export var cable_start_arc_min_angle: float = 0.0;
@export var cable_start_arc_max_angle: float = 2.0;

@export var cable_end_point_a: Vector2;
@export var cable_end_point_b: Vector2;

@export var cable_segments_min: int = 10;
@export var cable_segments_max: int = 20;

# @export var cable_segments_min: int = 10;
# @export var cable_segments_max: int = 20;

@export_group("")
@export_tool_button("Reload!") var b = _ready

@onready var label = $Label;
var bubble_center: Vector2

@onready var plug_button: TextureButton = $TextureRect;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bubble_center = get_combined_pivot_offset()
	label.text = display_text
	queue_redraw()

	var angles = RangeUtils.scattershot(cable_start_arc_max_angle, cables_count, cable_start_arc_min_angle);
	var anchors = RangeUtils.scattershot(1.0, cables_count);

	var b_min_a = cable_end_point_b - cable_end_point_a
	for i in range(cables_count):
		var end_pos = Node2D.new()
		end_pos.position = cable_end_point_a + b_min_a * anchors[i];
		
		var start_angle = angles[i];
		var start_pos = Node2D.new();
		start_pos.position = Vector2(cable_start_arc_radius, 0.0).rotated(start_angle) + get_combined_pivot_offset()
		var cb_node = VerletRope.new(start_pos, VerletRope.PIN_YES, end_pos, VerletRope.PIN_YES, Color.DARK_RED, 2, Vector2(0.0, 20.0));
		cb_node.rope_segments = randi_range(cable_segments_min, cable_segments_max);
		cb_node.color = cb_node.color.darkened(randf_range(0.0, 0.8));
		add_child(cb_node)
		move_child(cb_node, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	# draw_circle(bubble_center, cable_start_arc_radius, Color.AQUA)
	if(not check_when_run):
		draw_arc(bubble_center, cable_start_arc_radius, cable_start_arc_min_angle, cable_start_arc_max_angle, 20, Color.AQUA, 2.0)
		draw_line(cable_end_point_a, cable_end_point_b, Color.AQUAMARINE, 2)
