extends Node2D

@export var minScale := 1.0
@export var maxScale := 2.0

func _ready():

    if randf() < 0.5:
        $scale/sprite.flip_h = true

    $scale.scale = Vector2(1, 1) * randf_range(minScale, maxScale)
    $scale/sprite.frame = randi_range(0, $scale/sprite.hframes - 1)
