extends Node
class_name Hunger


@export var value := 0.0

var emitted := false
signal reached_zero


func _process(delta):

    if value > 0:
        value -= delta

    if value <= 0 and not emitted:
        value = 0
        reached_zero.emit()
        emitted = true
