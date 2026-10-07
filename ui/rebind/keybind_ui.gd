extends Node2D
class_name KeybindUI

@export_group("Display")
@export var display_text: String;

@export_group("Cable")
@export var cable_len_extended = 4.0;
@export var cable_len_shrunk = 1;

@onready var cable_rope = $CableRope;
@onready var plug_rope = $PlugRope;
@onready var plug_mouse_anchor = $PlugTip;
@onready var plug_button: TextureButton = $PlugButton;
@onready var label = $AKey/Label;

var plug_rope_gravity: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = display_text
	plug_rope_gravity = plug_rope.gravity
	set_active(false)

var is_active: bool = false;

func set_active(b: bool):
	is_active = b;
	if(b):
		plug_mouse_anchor.enable_follow = true;
		plug_rope.gravity = plug_rope_gravity
		cable_rope.pin_end_node = 0;
		plug_rope.pin_start_node = 1;
		cable_rope.set_segment_length(cable_len_extended);
	else:
		plug_mouse_anchor.enable_follow = false;
		plug_rope.gravity = cable_rope.gravity;
		cable_rope.pin_end_node = 1;
		plug_rope.pin_start_node = 0;
		cable_rope.set_segment_length(cable_len_shrunk);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
