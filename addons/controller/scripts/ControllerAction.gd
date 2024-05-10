@tool
@icon("res://addons/pawn/icons/controlleraction.svg")
extends Node
class_name ControllerAction

#region Variables
@export var node: Node:
	set(n):
		node = n
		notify_property_list_changed()

var signal_name: String
var command: String
var internal_value
var signal_type: int = -1
var is_in_controller_group = false

const types = {
	-1: "Empty",
	5: "Vector2",
	2: "Integer",
	3: "Float",
	1: "Boolean"
}
#endregion

#region Extend Methods
func enable_choose_type():
	return true
	
func value_in_editor():
	return true

func is_actionable():
	return true
	
func get_signal_type():
	return signal_type
	
func get_value():
	return internal_value
#endregion

#region Public Methods
func emit_signal_from_node_with_value(value):
	if node.has_signal(signal_name):
		var s = node.get(signal_name)
		
		if value != null:
			s.emit(value)
		else:
			s.emit()
	else:
		push_error("Method %s doesn't exist in %s" % [signal_name, node.name])

func trigger():
	emit_signal_from_node_with_value(get_value())
#endregion

#region Editor Methods
func _get_configuration_warnings():
	var warnings = []
	if !command and is_actionable():
		warnings.append("You cannot leave Action empty!")
	
	return warnings

func _get_property_list():
	var property_list = []
	
	if is_actionable():
		InputMap.load_from_project_settings()
		var input_actions = []
		for action_name in InputMap.get_actions():
			if !action_name.begins_with("ui_") and !action_name.begins_with("spatial"):
				input_actions.append(action_name)
				
		property_list.append({
			"name": "Action",
			"type": TYPE_STRING_NAME,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(input_actions)
		})
	
	if enable_choose_type() and !is_in_controller_group:
		property_list.append({
			"name": "Signal Type",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(types.values())
		})
		
	if !node:
		return property_list
		
	var options = []
	var signal_type = get_signal_type()
	
	for signal_obj in node.get_signal_list():
		var args_size = signal_obj.args.size()
		if (signal_type == -1 and args_size == 0) or (args_size > 0 and signal_type == signal_obj.args[0].type):
			options.append(signal_obj.name)
	
	if !is_in_controller_group:	
		property_list.append({
			"name": "Signal Name",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(options)
		})
	
	if signal_type != -1 and value_in_editor():
		property_list.append({
			"name": "Value",
			"type": signal_type,
		}) 
	
	return property_list

func _set(property, value):
	if property == &"Value":
		internal_value = value
	if property == &"Signal Name":
		signal_name = value
	elif property == &"Action":
		command = value
	elif property == &"Signal Type":
		for key in types.keys():
			if types[key] == value:
				signal_type = key
	
	update_configuration_warnings()
	notify_property_list_changed()
		
func _get(property):
	if property == &"Signal Name":
		return signal_name
	elif property == &"Action":
		return command
	elif property == &"Signal Type":
		return types.get(signal_type)
	elif property == &"Value":
		return internal_value

#endregion

func _ready():
	var parent = get_parent()
	
	if parent is ControllerGroup:
		is_in_controller_group = true
		node = parent.node
