@tool
@icon("res://addons/pawn/icons/controllergroup.svg")
extends ControllerAction
class_name ControllerGroup

var commands: Array[ControllerAction]
var output

func is_actionable():
	return false

func value_in_editor():
	return false
	
func _populate_child(child: ControllerAction):
	child.is_in_controller_group = true
	child.node = node
	child.signal_type = get_signal_type()
	child.notify_property_list_changed()

func _ready():
	for child in get_children():
		if child is ControllerAction:
			_populate_child(child)
			commands.append(child)
			
func _get_property_list():
	for child in get_children():
		if child is ControllerAction:
			_populate_child(child)
			commands.append(child)
	
	return []

func trigger():
	for command in commands:
		if Input.is_action_just_pressed(command.command):
			var out = command.get_value()
			if !output:
				output = out
			elif output is Vector2 or output is int or output is float:
				output += out
			elif output is bool:
				output = output and out
				
		if Input.is_action_just_released(command.command):
			var out = command.get_value()
			if output is Vector2 or output is int or output is float:
				output -= out
			elif output is bool:
				output = output and out

	if output != null:
		emit_signal_from_node_with_value(output)
