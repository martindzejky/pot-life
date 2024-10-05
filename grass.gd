extends Node2D

@export var minScale := 1.0
@export var maxScale := 2.0

func _ready():

    if randf() < 0.5:
        $sprite.flip_h = true

    $sprite.scale = Vector2(1, 1) * randf_range(minScale, maxScale)
    $sprite.frame = randi_range(0, $sprite.hframes - 1)
