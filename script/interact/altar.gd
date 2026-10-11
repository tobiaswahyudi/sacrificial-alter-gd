extends Sprite2D

@onready var collision_area: Area2D = $Area2D;
@onready var animation_player: AnimationPlayer = $AnimationPlayer;

@export var player_area: Area2D;
@export var rebinder_modal: RebinderWindow;

var player_touching_me: bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_area.area_entered.connect(thing_enter);
	collision_area.area_exited.connect(thing_leave);
	pass # Replace with function body.

func thing_enter(area: Area2D):
	if area == player_area:
		if not player_touching_me:
			player_touching_me = true
			animation_player.play("OpenPanel");
		
func thing_leave(area: Area2D):
	if area == player_area:
		if player_touching_me:
			animation_player.play("RESET");
			player_touching_me = false

func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	# Check for configured input map actions
	if event.is_action_pressed("ui_accept"):
		rebinder_modal.open();
		
