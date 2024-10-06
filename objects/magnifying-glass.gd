extends Node2D
class_name MagnifyingGlass


@export var fire: PackedScene


func _process(_delta):
    global_position = get_global_mouse_position()

func _input(event):
    if not event.is_action_pressed('shoot'): return
    if $shooting.time_left > 0: return
    if $cooling.time_left > 0: return

    #$laser.visible = true # I think it look better without the dot
    $shooting.start()
    $shoot.play()

    var object := fire.instantiate()
    get_tree().get_first_node_in_group('pot-inside').add_child(object)
    object.global_position = $laser.global_position
    object.global_position.y += 5


func shootingTimeout():
    $laser.visible = false
    $cooling.start()
