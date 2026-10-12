extends Node2D

@export var background: TextureButton
@export var keybinds: Array[KeybindUI]

@export var intents: Array[IntentUI]

@export var plug_offset: Vector2;

var active_keybind: StringName

func make_keybind_plug_clicked_callback(kb: KeybindUI):
	return func():
		if active_keybind == kb.name:
			return
		unclick_all()
		active_keybind = kb.name
		kb.set_active(true)

func make_intent_plug_clicked_callback(i: IntentUI):
	return func():
		# print(i.name,' clicked while ',active_keybind,' active')
		if active_keybind == '':
			return
		var a_kb_ui_index = keybinds.find_custom(
			func(s):
				return s.name == active_keybind
		)
		unclick_all()

		var kb: KeybindUI = keybinds[a_kb_ui_index];
		# print("index {0}, kb object {1}".format([a_kb_ui_index, str(kb)]));
		kb.set_plugged(i.global_position + plug_offset)

func unclick_all():
	for k in keybinds:
		if not k.is_plugged:
			k.set_active(false)
	active_keybind = ''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for kb in keybinds:
		kb.plug_button.pressed.connect(make_keybind_plug_clicked_callback(kb))
	for i in intents:
		i.plug_button.pressed.connect(make_intent_plug_clicked_callback(i))
	background.pressed.connect(unclick_all)
