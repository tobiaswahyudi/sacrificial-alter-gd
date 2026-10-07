extends Node2D

@export var enable_follow = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(enable_follow):
		self.global_position = get_global_mouse_position()
