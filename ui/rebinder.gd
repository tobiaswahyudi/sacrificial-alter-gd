@tool
extends Control
class_name RebinderWindow

@export_tool_button("Open") var o = open;
@export_tool_button("Close") var c = close;

@onready var animation_player: AnimationPlayer = $AnimationPlayer;

var is_open: bool = false;

func open():
	animation_player.play("in");
	is_open = true;

func close():
	animation_player.play("out");
	is_open = false;
