@tool
extends Control

@export_group("Switching")
@export var player: Player

@export_group("Display")
@export var bodies: Array[BodySprites.BodyType]
@export var entry_scene: PackedScene

var entries: Array[BodyStatusEntry]

var used: Array[bool] = []

@onready var entry_grid = $MarginContainer/GridContainer

func _ready() -> void:
	for idx in len(bodies):
		print("statusbar init entry ",idx)
		var body = bodies[idx]
		var entry_node: BodyStatusEntry = entry_scene.instantiate()
		used.append(false)
		entries.append(entry_node)
		entry_grid.add_child(entry_node)
		entry_node.used = false
		entry_node.body_type = body
		entry_node.key_number = idx + 1

# Is this the correct place for this logic? idk
func _input(event):
	for idx in len(bodies):
		var action_check_name = 'switch_' + str(idx + 1)
		if event.is_action_pressed(action_check_name):
			if not used[idx]:
				used[idx] = true
				entries[idx].used = true
				print("event is ", action_check_name, ". set used[",idx,"] to true ", used)
				player.change_body_type(bodies[idx])
