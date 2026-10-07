extends Node2D

@export var background: TextureButton
@export var keybinds: Array[KeybindUI]

var active_keybind: StringName

func make_keybind_plug_clicked_callback(kb: KeybindUI):
	return func():
		if active_keybind == kb.name:
			return
		active_keybind = kb.name
		for k in keybinds:
			k.set_active(false)
		kb.set_active(true)

func unclick_all():
	for k in keybinds:
		k.set_active(false)
	active_keybind = ''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for kb in keybinds:
		kb.plug_button.pressed.connect(make_keybind_plug_clicked_callback(kb))
	background.pressed.connect(unclick_all)
