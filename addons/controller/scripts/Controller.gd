@tool
@icon("res://addons/pawn/icons/controller.svg")
extends Node
class_name Controller

var commands: Array[ControllerAction]
var mouse_movement: ControllerMouseMovementAction2D


@export var capture_mouse_movement: bool:
	set(value):
		capture_mouse_movement = value
		update_configuration_warnings()
		
func _get_configuration_warnings():
	var warnings = []
	var mouse_action_counter = 0
	
	for child in get_children():
		if child is ControllerMouseMovementAction2D:
			mouse_action_counter += 1
	
	if mouse_action_counter == 0 and capture_mouse_movement:
		warnings.append("You need to have one ControllerMouseMovementAction as children")
	elif mouse_action_counter > 1:
		warnings.append("You have more than one ControllerMouseMovementAction")
	
	if mouse_action_counter > 0 and !capture_mouse_movement:
		warnings.append("You need to enable CaptureMouseMovement in Controller to make your action work properly")
	
	return warnings

func _get_property_list():
	return []
	
func _unhandled_input(event):
	if !capture_mouse_movement:
		return
		
	if event is InputEventMouseMotion:
		mouse_movement.internal_value = event.position
		mouse_movement.trigger()

func _ready():
	for child in get_children():
		if child is ControllerAction:
			if child is ControllerMouseMovementAction2D:
				mouse_movement = child
			else:
				commands.append(child)
		
func _process(_delta):
	if Engine.is_editor_hint():
		return

	for command in commands:
		var input_command = command.command
		if !input_command or Input.is_action_just_pressed(input_command):
			command.trigger()
