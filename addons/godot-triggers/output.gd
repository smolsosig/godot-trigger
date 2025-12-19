@icon("res://addons/godot-triggers/output.png")
class_name Output extends Resource

## What causes this output to fire. Examples include [code]area_entered[/code], [code]area_exited[/code], etc.
## [br][br][i]"My output named..."[/i]
@export var output: String
## The Node we are targeting.
## [br][br][i]"... targets entities named..."[/i]
@export var target: NodePath
## The name of the method (function) we're calling to the target.
## [br][br][i]"... via this input..."[/i]
@export var target_method: StringName
## The arguments to be passed along when calling the target method.
## [br][br][i]"... with a parameter override of..."[/i]
@export var arguments: Array[Variant]
## The number of seconds to wait after the output event occurs before firing.
## [br][br][i]"... after a delay in seconds of...[/i]
@export var delay: float = 0.0
