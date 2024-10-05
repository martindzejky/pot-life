extends Node2D
class_name Egg

@export var hatchOnReady := false
@export var creatures: Array[PackedScene] = []


func _ready():

    if hatchOnReady:
        hatch()
    else:
        $timer.start(randf_range(4, 10))


func hatch():

    $timer.stop()
    var creature := creatures.pick_random().instantiate() as Node2D
    get_parent().add_child(creature)
    creature.global_position = global_position + Vector2(0, 0.1)

    if hatchOnReady:
        queue_free()
    else:
        $animation.play('hatched')
