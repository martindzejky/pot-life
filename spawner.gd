extends Node
class_name Spawner

@export var bounds: CollisionShape2D
@export var grassObjects: Array[PackedScene] = []
@export var egg: PackedScene


func _ready():

    # grass
    for i in range(randi_range(10, 20)):
        var object := grassObjects.pick_random().instantiate() as Node2D
        spawnInBounds(object)

    # eggs
    for i in range(randi_range(8, 12)):
        var object := egg.instantiate() as Egg
        object.hatchOnReady = randf() < 0.8
        object.bounds = bounds
        spawnInBounds(object)


func spawnEgg():

    $timer.start(randf_range(4, 10))

    if get_tree().get_node_count_in_group('creature') < 20:
        if randf() < 0.6:
            var object := egg.instantiate() as Egg
            object.bounds = bounds
            spawnInBounds(object)
    elif get_tree().get_node_count_in_group('creature') < 100:
        if randf() < 0.2:
            var object := egg.instantiate() as Egg
            object.bounds = bounds
            spawnInBounds(object)


func spawnEggFromCreature(creature: Creature):

    var object := egg.instantiate() as Egg
    object.bounds = bounds
    object.global_position = creature.global_position
    get_parent().add_child.call_deferred(object)


func spawnInBounds(object: Node2D):

    var rect := bounds.shape.get_rect()

    var position := Vector2(
        randf_range(rect.position.x, rect.end.x),
        randf_range(rect.position.y, rect.end.y),
    ) + bounds.global_position

    get_parent().add_child.call_deferred(object)
    object.global_position = position
