@tool
extends Bindings.BindModule
class_name DoubleTapModule

var last_triggered: int
var powered: bool
var triggering: bool

# This is kind of a constant / game tweak
var doubletap_threshold: int = 450;

func _init(p_name: String) -> void:
	super("Doubletap_"+p_name);
	last_triggered = 0;
	powered = false;

func is_firing() -> bool:
	return triggering

func trigger_on(timestamp: int, actor: String):
	if powered:
		return
	powered = true;
	if timestamp - last_triggered < doubletap_threshold:
		triggering = true
		for o in outputs:
			if o.bound != null:
				o.bound.trigger_on(timestamp, name)
	last_triggered = timestamp

func trigger_off(timestamp: int, actor: String):
	powered = false;
	triggering = false;
