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
var I_SLIDE_RIGHT = "intent_left"

var INTENTS = [
	I_RIGHT,
	I_UP,
	I_LEFT,
	I_SLIDE_RIGHT
]

var STRINGS: Dictionary[String, String] = {
	KB_LEFT: "A",
	KB_RIGHT: "D",
	KB_UP: "W",
	I_LEFT: "walk\nleft",
	I_RIGHT: "walk\nright",
	I_UP: "jump",
	I_SLIDE_RIGHT: "slide\nright",
	"Doubletap_": "double\ntap"
}

var keybind_nodes: Dictionary[String, KeyBindNode] = {}

var intent_nodes: Dictionary[String, IntentNode] = {}

var nodes: Dictionary[String, BindNode] = {}

@warning_ignore("UNUSED_SIGNAL")
signal bind_altered();

enum PortType {
	Trs, Usb, Worm, Neuron
};

class BindPort:
	var name: String
	var type: PortType
	var bound: BindNode
	func _init(p_name: String, p_type: PortType) -> void:
		name = p_name
		type = p_type
		bound = null

class BindNode:
	var name: String
	var inputs: Array[BindPort]
	var outputs: Array[BindPort]

	func _init(p_name: String) -> void:
		name = p_name
		inputs = []
		outputs = [BindPort.new("default", PortType.Usb)]

	func is_firing() -> bool:
		return false;

	func trigger_on(timestamp: int, actor: String):
		pass

	func trigger_off(timestamp: int, actor: String):
		pass

	func connect_output(index: int, rhs: BindNode):
		self.outputs[index].bound = rhs
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
			if o.bound != null:
				o.bound.trigger_on(timestamp, name)

	func trigger_off(timestamp: int, actor: String):
		if(not key_pressed):
			# Already unpressed; prune
			return
		key_pressed = false;
		for o in outputs:
			if o.bound != null:
				o.bound.trigger_off(timestamp, name)

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

class BindModule extends BindNode:
	# Modules need to keep input/outputs ordered
	func _init(p_name: String) -> void:
		super(p_name)

func register_node(node: BindNode):
	nodes[node.name] = node

func _ready() -> void:
	for bind in BINDS:
		var node = KeyBindNode.new(bind)
		keybind_nodes[bind] = node
		register_node(node)

	for intent in INTENTS:
		var node = IntentNode.new(intent)
		intent_nodes[intent] = node
		register_node(node)
	
	keybind_nodes[KB_LEFT].connect_output(0, intent_nodes[I_LEFT])
	keybind_nodes[KB_RIGHT].connect_output(0, intent_nodes[I_RIGHT])

	var dbt_module = DoubleTapModule.new("")
	register_node(dbt_module)

	keybind_nodes[KB_UP].connect_output(0, dbt_module)
	dbt_module.connect_output(0, intent_nodes[I_UP])
	# kb_up.connect_output(i_up)

func _process(_delta: float) -> void:
	var timestamp = Time.get_ticks_msec()
	for key in keybind_nodes:
		var kb = keybind_nodes[key]
		if Input.get_action_strength(kb.name) > 0.9:
			kb.trigger_on(timestamp, "System");
		else:
			kb.trigger_off(timestamp, "System");
