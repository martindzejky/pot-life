extends Node2D

@export var minScale := 1
@export var maxScale := 2

func _ready():

    if randf() < 0.5:
        $sprite.flip_h = true

    $sprite.scale = Vector2(1, 1) * randf_range(1, 2)
    $sprite.frame = randi_range(0, $sprite.hframes - 1)
