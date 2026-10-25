@tool
extends HBoxContainer

var key_sprite_list: KeySpriteList = preload("res://ui/util/key_sprites.tres")
var body_sprite_mapping: BodySprites = preload("res://ui/util/body_sprites.tres")

@export var used: bool = false:
	set(v):
		used = v
		update_appearances()

@export var body_type: BodySprites.BodyType:
	set(v):
		body_type = v
		update_appearances()

@export var key_number: int:
	set(v):
		key_number = v
		update_appearances()

func update_appearances():
	blood_texture_rect.visible = used
	body_texture_rect.texture = body_sprite_mapping.mapping.get(body_type)
	key_texture_rect.texture = key_sprite_list.list[key_number]
	if used:
		key_texture_rect.texture = key_sprite_list.secondary[key_number]


@onready var body_texture_rect: TextureRect = $CenterContainer/Body
@onready var blood_texture_rect: TextureRect = $CenterContainer/Blood
@onready var key_texture_rect: TextureRect = $Key
