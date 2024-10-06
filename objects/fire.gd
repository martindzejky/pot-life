extends Node2D


func _ready():
    $timer.start(randf_range(3, 4))


func die():
    queue_free()


func hurt():

    var targets := get_tree().get_nodes_in_group('creature')
    var grass := get_tree().get_nodes_in_group('grass')
    targets.append_array(grass)

    $hurt.play()

    for object in targets:
        var distance = object.global_position.distance_squared_to(global_position)
        if distance > 700: continue

        object.hurtByFire()
