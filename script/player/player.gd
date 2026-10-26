class_name Player
extends CharacterBody2D

@export_group("Verticals")
@export var GRAVITY: float = 900.0;
@export var JUMP_HEIGHT: float = 50.0;

@export_group("Horizontals")
@export var MOVE_TYPE: MoveType
@export var WALK_SPEED: float = 300.0
@export var CRAWL_SPEED: float = 150.0
@export var CRAWL_HALF_PERIOD_MILLIS: int = 800

@onready var sprite: AnimatedSprite2D = $Sprite

var JUMP_SPEED: float

var face_direction_left: bool = false
var is_moving: bool = false

enum MoveType {
	NotMoving, Walk, Crawl
}

var last_key_press_millis: int = 0
var move_type: MoveType = MoveType.Walk

func _ready():
	# Max height is (v^2)/(2g); thus v = sqrt(2gh)
	JUMP_SPEED = sqrt(JUMP_HEIGHT * GRAVITY * 2.0)

func _physics_process(delta: float) -> void:
	var time_millis = Time.get_ticks_msec()

	if GameState.player_paralyzed:
		return
	var direction: float = Input.get_axis("ui_left", "ui_right")

	if direction == 0:
		do_move(MoveType.NotMoving)
	else:
		face_direction_left = direction < 0
		sprite.flip_h = face_direction_left
		do_move(MOVE_TYPE)

	if is_on_floor():
		if Input.is_action_pressed("ui_up"):
			velocity.y = - JUMP_SPEED
	else:
		velocity.y += GRAVITY * delta

	match move_type:
		MoveType.NotMoving:
			velocity.x = 0.0
		MoveType.Walk:
			velocity.x = direction * WALK_SPEED
		MoveType.Crawl:
			var immediate_speed = max(0, cos(float((time_millis - last_key_press_millis)) / CRAWL_HALF_PERIOD_MILLIS * PI))
			# integral of max(0, cos x) [2 pi, 0] is 2
			# thus average is 1/pi; so we mult by pi.
			velocity.x = direction * immediate_speed * CRAWL_SPEED * PI

	move_and_slide()

	if velocity.x < 0:
		face_direction_left = true
	elif velocity.x > 0:
		face_direction_left = false

func do_move(target_type: MoveType):
	var time_millis = Time.get_ticks_msec()
	if move_type != target_type:
		last_key_press_millis = time_millis
	move_type = target_type
