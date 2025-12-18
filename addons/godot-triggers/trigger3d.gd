@icon("res://addons/godot-triggers/trigger3d_icon.png")
class_name Trigger3D extends Area3D
## An [code]Area3D[/code] which responds to the presence of other areas/bodies.

## If [code]false[/code], disables trigger on startup. It will need to be manually reenabled by
## calling the trigger's [code]enable_monitoring()[/code] method or simply setting the trigger's[code]monitored[/code] property to [code]true[/code].
@export var enable_on_start: bool = true
## If [code]true[/code], trigger can be fired multiple times. Leave as [code]false[/code] for
## one-time triggers, which immediately set [code]monitoring[/code] to [code]false[/code].
@export var repeatable: bool = false
@export_group("Outputs")
## The complete list of outputs the Trigger will emit.
@export var outputs: Array[Output]

var _on_body_entered_outputs: Array
var _on_body_exited_outputs: Array
var _on_area_entered_outputs: Array
var _on_area_exited_outputs: Array

func _ready() -> void:
	set_deferred("monitorable", false)
	set_deferred("monitoring", enable_on_start)
	
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	connect("area_entered", _on_area_entered)
	connect("area_exited", _on_area_exited)
	
	if outputs:
		for _output: Output in outputs:
			assert(_output.output, "Missing output.")
			assert(_output.target, "Missing target.")
			assert(_output.target_method, "Missing target method.")
			match _output.output:
				"body_entered":
					_on_body_entered_outputs.append(_output)
				"body_exited":
					_on_body_exited_outputs.append(_output)
				"area_entered":
					_on_area_entered_outputs.append(_output)
				"area_exited":
					_on_area_exited_outputs.append(_output)

#region Emit outputs
func _on_body_entered(_body: Node3D) -> void:
	if not repeatable:
		set_deferred("monitoring", false)
	_emit_outputs(_on_body_entered_outputs)


func _on_area_entered(_area: Area3D) -> void:
	if not repeatable:
		set_deferred("monitoring", false)
	_emit_outputs(_on_area_entered_outputs)


func _on_body_exited(_area: Node3D) -> void:
	_emit_outputs(_on_body_exited_outputs)


func _on_area_exited(_area: Area3D) -> void:
	_emit_outputs(_on_area_exited_outputs)
#endregion

func _emit_outputs(_outputs: Array) -> void:
	var num: int = 0
	for n: Output in _outputs:
		var target: Node = get_node(_outputs[num].target)
		var target_method: StringName = _outputs[num].target_method
		var arguments: Array = _outputs[num].arguments
		var delay: float = _outputs[num].delay
		
		if delay:
			var timer: SceneTreeTimer = get_tree().create_timer(delay)
			timer.timeout.connect(func() -> void: _emit_delayed_output(num))
		else:
			_emit_output(target, target_method, arguments)
		
		num += 1


func _emit_output(target: Node, target_method: StringName, arguments: Array) -> void:
		if target.has_method(target_method):
			if arguments:
				target.callv(target_method, arguments)
			else:
				target.call(target_method)
		else:
			if arguments:
				push_warning("Attempted to call non-existent method \"%s\" with args \"%s\" on
						%s, ignoring." % [target_method, arguments, target])
			else:
				push_warning("Attempted to call non-existent method \"%s\" on %s, ignoring." %
						[target_method, target])


func _emit_delayed_output(num: int) -> void:
	var target: Node = get_node(outputs[num].target)
	var target_method: StringName = outputs[num].target_method
	var arguments: Array = outputs[num].arguments
	var delay: float = outputs[num].delay
	
	_emit_output(target, target_method, arguments)


## Enables or disables monitoring on the trigger. This is just a fancy way of writing [code]set_deferred("monitoring", true/false)[/code].
func enable_monitoring(enable: bool = true) -> void:
	set_deferred("monitoring", enable)
