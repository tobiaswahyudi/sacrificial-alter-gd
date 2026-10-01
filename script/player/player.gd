class_name Player
extends CharacterBody2D

@export var paused: bool = false

@export_group("Movement")
@export var SPEED: float = 300.0
@export var GRAVITY: float = 900.0;
@export var JUMP_HEIGHT: float = 50.0;

var JUMP_SPEED: float

var face_direction_left: bool = false

# Item-holding state (pickup)

# Interaction state
var targeted_item: Node2D

func _ready():
  # Max height is (v^2)/(2g); thus v = sqrt(2gh)
  JUMP_SPEED = sqrt(JUMP_HEIGHT * GRAVITY * 2.0)

func _physics_process(delta: float) -> void:
  if paused:
      return
  var direction: float = Input.get_axis("ui_left", "ui_right")

  if is_on_floor():
    if Input.is_action_pressed("ui_up"):
      velocity.y = -JUMP_SPEED
  else:
    velocity.y += GRAVITY * delta

  velocity.x = direction * SPEED
  move_and_slide()
  
  if velocity.x < 0:
    face_direction_left = true
  elif velocity.x > 0:
    face_direction_left = false
