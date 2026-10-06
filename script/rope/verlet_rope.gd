extends Node2D

@export_group("Nodes")
@export_subgroup("Start Node")
@export var start_node: Node2D
@export_enum("Yes", "No") var pin_start_node: int = 1
@export_subgroup("End Node")
@export var end_node: Node2D
@export_enum("Yes", "No") var pin_end_node: int = 1

@export_group("Rope")
@export var rope_segments: int
@export var target_segment_length: float
var segment_length: float
@export var constraint_iterations: int
@export var gravity: Vector2
# makes sense for UI
@export_range(0.0, 1.0) var velocity_dampen: float = 0.0
var vel_dampen_actual;

@export_group("Display")
@export var color: Color
@export var start_weight: float
@export var end_weight: float
@export_enum("Linear", "Stretch") var weight_interp: int;

var old_pos: Array[Vector2];
var cur_pos: Array[Vector2];

func _ready() -> void:
	vel_dampen_actual = 1.0 - velocity_dampen;

	var last_pos = start_node.position;
	var delta_pos = (end_node.position - last_pos) / rope_segments;

	for i in range(rope_segments + 1):
		cur_pos.append(last_pos)
		old_pos.append(last_pos)
		last_pos += delta_pos
	
	segment_length = target_segment_length

func verlet_integrate_one(time: float, i: int) -> void:
	var velocity = cur_pos[i] - old_pos[i];
	var grav_contribution = gravity * time;

	old_pos[i] = cur_pos[i];
	cur_pos[i] += (velocity * vel_dampen_actual) + grav_contribution;

func verlet_integrate(time: float) -> void:
	for i in range(rope_segments + 1):
		# if pinned, don't touch
		if (i == 0 && pin_start_node == 0):
			continue ;
		if (i == rope_segments && pin_end_node == 0):
			continue ;
		# integrate
		verlet_integrate_one(time, i);
	

func constraint_relax_one_iter() -> void:
	for i in range(rope_segments):
		var aNode = cur_pos[i];
		var bNode = cur_pos[i + 1];

		var aNodeWeight = float(pin_start_node if (i == 0) else 1);
		var bNodeWeight = float(1 if (aNodeWeight == 0) else pin_end_node if (i == rope_segments) else 1);

		var deltaPos = aNode - bNode;
		var segLen = deltaPos.length();

		var tooLongFactor = (segment_length - segLen) / segLen;

		var nudge = deltaPos * tooLongFactor;

		var totalWeight = aNodeWeight + bNodeWeight;

		cur_pos[i] += nudge * (aNodeWeight / totalWeight);
		cur_pos[i + 1] -= nudge * (bNodeWeight / totalWeight);

func _process(delta: float) -> void:
	cur_pos[0] = start_node.position
	cur_pos[rope_segments] = end_node.position
	verlet_integrate(delta)
	if (pin_start_node + pin_end_node == 0):
		segment_length = max(target_segment_length, (cur_pos[0] - cur_pos[rope_segments]).length() / rope_segments)
	for i in range(constraint_iterations):
		constraint_relax_one_iter();

	if (pin_start_node == 1):
		start_node.position = cur_pos[0]
	if (pin_end_node == 1):
		end_node.position = cur_pos[rope_segments]

	queue_redraw()

func _draw() -> void:
	for i in range(rope_segments):
		draw_line(cur_pos[i], cur_pos[i + 1], color, start_weight)
