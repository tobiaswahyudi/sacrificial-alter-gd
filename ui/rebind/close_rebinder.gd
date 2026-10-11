extends TextureButton

@export var rebinder: RebinderWindow;

func _ready() -> void:
	self.pressed.connect(rebinder.close)
