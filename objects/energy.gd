extends Node
class_name Energy


@export var value := 0.0

var emitted := false
signal reached_zero


func _process(delta):

    if not emitted:
        value += delta

    if value <= 0 and not emitted:
        value = 0
        reached_zero.emit()
        emitted = true
