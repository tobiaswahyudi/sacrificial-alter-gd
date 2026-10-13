@tool
extends Node

var KB_LEFT = "ui_left";
var KB_RIGHT = "ui_right";
var KB_UP = "ui_up";

var BINDS = [
	KB_RIGHT,
	KB_UP,
	KB_LEFT
]

var I_LEFT = "intent_left";
var I_RIGHT = "intent_right";
var I_UP = "intent_up";

var INTENTS = [
	I_RIGHT,
	I_UP,
	I_LEFT
]

var STRINGS: Dictionary[String, String] = {
	KB_LEFT: "A",
	KB_RIGHT: "D",
	KB_UP: "W",
	I_LEFT: "walk\nleft",
	I_RIGHT: "walk\nright",
	I_UP: "jump",
}

var keybind_nodes: Dictionary[String, KeyBindNode] = {}

var intent_nodes: Dictionary[String, IntentNode] = {}

var nodes: Dictionary[String, BindNode] = {}

@warning_ignore("UNUSED_SIGNAL")
signal bind_altered();

class BindNode:
	var name: String
	var inputs: Array[BindNode]
	var outputs: Array[BindNode]

	func _init(p_name: String) -> void:
		name = p_name
		inputs = []
		outputs = []

	func is_firing() -> bool:
		return false;

	func trigger_on(timestamp: int, actor: String):
		pass

	func trigger_off(timestamp: int, actor: String):
		pass

	func connect_output(rhs: BindNode):
		self.outputs.append(rhs)
		rhs.inputs.append(self)

class KeyBindNode extends BindNode:
	var key_pressed: bool

	func _init(p_bind_name: String) -> void:
		super(p_bind_name)

	func trigger_on(timestamp: int, actor: String):
		if(key_pressed):
			# Already pressed; prune
			return
		key_pressed = true;
		for o in outputs:
			o.trigger_on(timestamp, name)

	func trigger_off(timestamp: int, actor: String):
		if(not key_pressed):
			# Already unpressed; prune
			return
		key_pressed = false;
		for o in outputs:
			o.trigger_off(timestamp, name)

	func is_firing() -> bool:
		return key_pressed;

class IntentNode extends BindNode:
	var firing: bool

	func _init(p_intent_name: String) -> void:
		super(p_intent_name)

	func trigger_on(timestamp: int, actor: String):
		firing = true;

	func trigger_off(timestamp: int, actor: String):
		firing = false;

	func is_firing() -> bool:
		return firing;

func _ready() -> void:
	var kb_left = KeyBindNode.new(KB_LEFT)
	var kb_right = KeyBindNode.new(KB_RIGHT)
	var kb_up = KeyBindNode.new(KB_UP)

	keybind_nodes[KB_LEFT] = kb_left
	keybind_nodes[KB_RIGHT] = kb_right
	keybind_nodes[KB_UP] = kb_up

	var i_left = IntentNode.new(I_LEFT)
	var i_right = IntentNode.new(I_RIGHT)
	var i_up = IntentNode.new(I_UP)

	intent_nodes[I_LEFT] = i_left
	intent_nodes[I_RIGHT] = i_right
	intent_nodes[I_UP] = i_up

	# Push all nodes from keybind and intent into nodes
	for b_name in keybind_nodes:
		nodes[b_name] = keybind_nodes[b_name]
	for b_name in intent_nodes:
		nodes[b_name] = intent_nodes[b_name]

	kb_left.connect_output(i_left)
	kb_right.connect_output(i_right)
	# kb_up.connect_output(i_up)

func _process(_delta: float) -> void:
	var timestamp = Time.get_ticks_msec()
	for key in keybind_nodes:
		var kb = keybind_nodes[key]
		if Input.get_action_strength(kb.name) > 0.9:
			kb.trigger_on(timestamp, "System");
		else:
			kb.trigger_off(timestamp, "System");
