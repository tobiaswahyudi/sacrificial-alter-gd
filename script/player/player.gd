class_name Player
extends CharacterBody2D

# @export_group("Body")
# BodySprites is 100% the wrong place for this enum. Sucks to be the solo dev i guess
@export var body_type: BodySprites.BodyType

@export_group("Verticals")
@export var GRAVITY: float = 900.0;
@export var JUMP_HEIGHT: float = 50.0;

@export_group("Horizontals")
@export var WALK_SPEED: float = 300.0
@export var CRAWL_SPEED: float = 150.0
@export var CRAWL_HALF_PERIOD_MILLIS: int = 800

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var move_controller: PlayerMovement

var JUMP_SPEED: float

# var face_direction_left: bool = false
# var is_moving: bool = false

# var last_key_press_millis: int = 0
# var move_type: MoveType = MoveType.Walk

func change_body_type(target: BodySprites.BodyType):
	if body_type == target:
		return
	body_type = target
	match target:
		BodySprites.BodyType.Human:
			animation_player.play("walk")
			move_controller = WalkMovement.new(self)
		BodySprites.BodyType.CrawlHuman:
			animation_player.play("crawl")
			move_controller = CrawlMovement.new(self)
		BodySprites.BodyType.Frog:
			animation_player.play("frog")
			move_controller = FrogMovement.new(self)
		BodySprites.BodyType.Fish:
			animation_player.play("fish")
			move_controller = FishMovement.new(self)
		

func _ready():
	# Max height is (v^2)/(2g); thus v = sqrt(2gh)
	JUMP_SPEED = sqrt(JUMP_HEIGHT * GRAVITY * 2.0)
	var actual_body_type = body_type
	body_type = (body_type + 1) as BodySprites.BodyType # hehe
	change_body_type(actual_body_type)

func _physics_process(delta: float) -> void:
	if GameState.player_paralyzed:
		return

	var up_pressed = Input.is_action_pressed("ui_up")

	var h_dir: float = Input.get_axis("ui_left", "ui_right")

	move_controller.move(delta, up_pressed, h_dir)

func _draw() -> void:
	move_controller.render()

class PlayerMovement:
	var player: Player
	func _init(p_player: Player) -> void:
		player = p_player

	func move(_delta: float, _up: bool, _dir: float) -> void:
		assert(false, "func move() in PlayerMovement must be overridden")
	func render() -> void:
		assert(false, "func render() in PlayerMovement must be overridden")

class WalkMovement extends PlayerMovement:
	func move(delta: float, up: bool, dir: float) -> void:
		if player.is_on_floor():
			if up:
				player.velocity.y = - player.JUMP_SPEED
		else:
			player.velocity.y += player.GRAVITY * delta

		player.velocity.x = dir * player.WALK_SPEED

		if dir != 0:
			player.sprite.flip_h = dir < 0
		player.move_and_slide()

	func render() -> void:
		pass

class CrawlMovement extends PlayerMovement:
	var last_key_press_millis: float = 0
	var is_moving: bool = false

	func move(delta: float, up: bool, dir: float) -> void:
		var time_millis = Time.get_ticks_msec()
		if dir == 0:
			is_moving = false
		else:
			if not is_moving:
				last_key_press_millis = time_millis
			is_moving = true
		
		if player.is_on_floor():
			if up:
				player.velocity.y = - player.JUMP_SPEED
		else:
			player.velocity.y += player.GRAVITY * delta

		var immediate_speed = max(0, cos(float((time_millis - last_key_press_millis)) / player.CRAWL_HALF_PERIOD_MILLIS * PI))
		# integral of max(0, cos x) [2 pi, 0] is 2
		# thus average is 1/pi; so we mult by pi.
		player.velocity.x = dir * immediate_speed * player.CRAWL_SPEED * PI
		if dir != 0:
			player.sprite.flip_h = dir < 0
		player.move_and_slide()

	func render() -> void:
		pass

class FrogMovement extends PlayerMovement:
	var angle: float = false

	var ANGLE_ROTATE_SPEED = 1.0
	var ANGLE_ROTATE_LIMIT = PI * 0.4

	var LINE_LENGTH: float = 100.0
	var is_on_wall: bool = false

	var wall_grip_start_time: float = 0.0

	var WALL_CLING_DELAY_MS = 200
	var WALL_SLIDE_RAMP_MS = 250
	var WALL_SLIDE_SPEED = 60.0

	var WALL_JUMP_ANGLE = PI / 4

	func launch():
		var launch_vel = Vector2(0.0, -player.JUMP_SPEED).rotated(angle)
		player.velocity = launch_vel
		angle = 0

	func move(delta: float, up: bool, dir: float) -> void:
		var time_millis = Time.get_ticks_msec()
		if player.is_on_floor():
			player.velocity = Vector2()
			angle += dir * ANGLE_ROTATE_SPEED * delta
			angle = clampf(angle, -ANGLE_ROTATE_LIMIT, ANGLE_ROTATE_LIMIT)
			if up:
				launch()
			is_on_wall = false
		elif player.is_on_wall_only():
			if not is_on_wall:
				wall_grip_start_time = time_millis
				var player_collision = player.get_last_slide_collision()
				var collision_normal = player_collision.get_normal()
				angle = WALL_JUMP_ANGLE * collision_normal.x
				is_on_wall = true
			var cling_time = time_millis - wall_grip_start_time
			var y_vel = 0
			if cling_time > WALL_CLING_DELAY_MS + WALL_SLIDE_RAMP_MS:
				y_vel = WALL_SLIDE_SPEED
			elif cling_time > WALL_CLING_DELAY_MS:
				y_vel = WALL_SLIDE_SPEED * (cling_time - WALL_CLING_DELAY_MS) / WALL_SLIDE_RAMP_MS
			player.velocity.y = y_vel
			if up:
				launch()
		else:
			angle = 0
			is_on_wall = false
			player.velocity.y += player.GRAVITY * delta

		if angle != 0:
			player.sprite.flip_h = angle < 0
		player.move_and_slide()
		player.queue_redraw()

	func render() -> void:
		if angle == 0:
			return
		player.draw_line(Vector2(0, 0), Vector2(0, -LINE_LENGTH).rotated(angle), Color.RED, 2)

class FishMovement extends PlayerMovement:
	var launch_height: float = 0.0
	var sprite_starting_rotation: float

	var FLOP_ANGLE_LIMIT = 0.6
	var FLOP_PER_MILLIS_FREQUENCY: float = 20.0 / 1000.0

	var noise: Noise

	func _init(p_player: Player) -> void:
		super(p_player)
		noise = FastNoiseLite.new()

	func move(delta: float, up: bool, _dir: float) -> void:
		var time_millis = Time.get_ticks_msec()

		if player.is_on_floor():
			player.velocity = Vector2()
			if up:
				sprite_starting_rotation = player.sprite.rotation
				launch_height = player.position.y
				var launch_vel = Vector2(0.0, -player.JUMP_SPEED)
				player.velocity = launch_vel
		else:
			player.velocity.y += player.GRAVITY * delta
			var cur_height = launch_height - player.position.y
			var jump_rate = cur_height / player.JUMP_HEIGHT
			var flop_angle_delta = sin((time_millis + noise.get_noise_1d(time_millis)) * FLOP_PER_MILLIS_FREQUENCY) * jump_rate * FLOP_ANGLE_LIMIT
			player.sprite.rotation = sprite_starting_rotation + flop_angle_delta

		player.move_and_slide()
