@tool
@icon("res://addons/pawn/icons/controllermousemovement.svg")
extends ControllerAction
class_name ControllerMouseMovementAction2D

@export var use_global = true:
	set(v):
		use_global = v
		update_configuration_warnings()
		
@onready var root = get_root_node()

func get_root_node():
	return EditorInterface.get_edited_scene_root() if Engine.is_editor_hint() else get_tree().root.get_child(0)
		
func get_signal_type():
	return TYPE_VECTOR2

func get_value():
	if root is Node2D and use_global:
		return root.get_global_mouse_position()
		
	return internal_value

func is_actionable():
	return false

func enable_choose_type():
	return false
	
func value_in_editor():
	return false

func _get_configuration_warnings():
	if get_root_node() is Node2D:
		return []
		
	return ["Use global will be ignored for non 2D scenes"]
	
