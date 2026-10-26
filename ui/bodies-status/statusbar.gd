@tool
extends Control

@export var bodies: Array[BodySprites.BodyType]
@export var entry_scene: PackedScene

var entries: Array[BodyStatusEntry]
@export var used: Array[bool]:
	set(v):
		used = v
		for idx in len(used):
			entries[idx].used = used[idx]

@onready var entry_grid = $MarginContainer/GridContainer

func _ready() -> void:
	used = []
	for idx in len(bodies):
		var body = bodies[idx]
		var entry_node: BodyStatusEntry = entry_scene.instantiate()
		used.append(false)
		entries.append(entry_node)
		entry_grid.add_child(entry_node)
		entry_node.used = false
		entry_node.body_type = body
		entry_node.key_number = idx + 1
