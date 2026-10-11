@tool
extends Node

var last_used_altar_position: Vector2;
var rebinder_modal_open: bool = false;

var player_paralyzed: bool:
	get():
		return rebinder_modal_open
