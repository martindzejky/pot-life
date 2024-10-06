extends Node
class_name Hunger


@export var value := 0.0
signal reached_zero


func _process(delta):

    if value > 0:
        value -= delta

        if value <= 0:
            value = 0
            reached_zero.emit()
