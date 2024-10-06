extends Node2D
class_name Egg

@export var hatchOnReady := false
@export var evil := false
@export var bounds: CollisionShape2D
@export var creatures: Array[PackedScene] = []
@export var evilCreatures: Array[PackedScene] = []


func _ready():

    if hatchOnReady:
        hatch()
    else:
        $timer.start(randf_range(4, 10))
        $animation.advance(randf())


func hatch():

    $timer.stop()

    var pool = creatures
    if evil: pool = evilCreatures

    var creature := pool.pick_random().instantiate() as Node2D
    get_parent().add_child(creature)
    creature.global_position = global_position
    creature.bounds = bounds
    creature.evil = evil

    if hatchOnReady:
        queue_free()
    else:
        $animation.play('hatched')
