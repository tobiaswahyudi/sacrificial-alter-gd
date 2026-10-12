@tool
extends Node2D

class_name VerletRope

static var PIN_YES: int = 0;
static var PIN_NO: int = 1;

@export_group("Nodes")
@export_subgroup("Start Node")
@export var start_node: Node2D
@export_enum("Yes", "No") var pin_start_node: int
@export_subgroup("End Node")
@export var end_node: Node2D
@export_enum("Yes", "No") var pin_end_node: int

@export_group("Rope")
@export var rope_segments: int = 20;
@export var target_segment_length: float = 2.0;
var segment_length: float
@export var constraint_iterations: int = 2;
@export var gravity: Vector2; # = Vector2(0.0, 20.0);
# makes sense for UI
@export_range(0.0, 1.0) var velocity_dampen: float = 0.03;
var vel_dampen_actual;

@export_group("Display")
@export var color: Color
@export var start_weight: float
@export var end_weight: float
@export_enum("Linear", "Stretch") var weight_interp: int;

@export_group("")
@export_tool_button("Reload!") var b = _ready

var old_pos: Array[Vector2];
var cur_pos: Array[Vector2];

func _init(
	_start_node: Node2D = null,
	_pin_start_node: int = 2,
	_end_node: Node2D = null,
	_pin_end_node: int = 2,
	_color: Color = Color.AQUA,
	_weight: float = -1,
	_gravity: Vector2 = Vector2(0, 0)
) -> void:
	if (_start_node != null):
		self.start_node = _start_node
	if (_pin_start_node != 2):
		self.pin_start_node = _pin_start_node
	if (_end_node != null):
		self.end_node = _end_node
	if (_pin_end_node != 2):
		self.pin_end_node = _pin_end_node
	self.color = _color
	if(_weight >= 0):
		self.start_weight = _weight
	if(_gravity.length() > 0.01):
		self.gravity = _gravity;

func _ready() -> void:
	vel_dampen_actual = 1.0 - velocity_dampen;

	var last_pos = start_node.position;
	var delta_pos = (end_node.position - last_pos) / rope_segments;

	for i in range(rope_segments + 1):
		cur_pos.append(last_pos)
		old_pos.append(last_pos)
		last_pos += delta_pos
	
	segment_length = target_segment_length
	
func set_segment_length(v: float):
	segment_length = v
	target_segment_length = v

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
