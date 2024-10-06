extends Node2D
class_name Grass

@export var minScale := 1.0
@export var maxScale := 2.0

func _ready():

    if randf() < 0.5:
        $scale/sprite.flip_h = true

    $scale.scale = Vector2(1, 1) * randf_range(minScale, maxScale)
    $scale/sprite.frame = randi_range(0, $scale/sprite.hframes - 1)

    $energy.value = randf_range(10, 20)

func die():

    queue_free()

    # need to move the death sound to the parent so it is not destroyed with the grass
    var sound := $death as AudioStreamPlayer2D
    remove_child(sound)
    get_parent().add_child(sound)
    sound.global_position = global_position
    sound.play()
    # should self-destruct once done playing
