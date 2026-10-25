class_name BodySprites
extends Resource

enum BodyType {
	Human,
	Frog,
	Fish
}

@export var mapping: Dictionary[BodyType, Texture2D]
