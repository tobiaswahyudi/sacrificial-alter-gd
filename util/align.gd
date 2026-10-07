extends Control

@export var anchor: Node2D
@export var look_at: Node2D
@export var look_away: bool

var look_away_offset: float
var my_offset: Vector2

func _ready() -> void:
	my_offset = pivot_offset_ratio * size
	look_away_offset = PI if look_away else 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position = anchor.position - my_offset
	self.rotation = anchor.position.angle_to_point(look_at.position) + look_away_offset
