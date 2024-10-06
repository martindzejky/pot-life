extends Node2D

func _ready():
    if randf() < 0.5:
        $big.flip_h = true
        $small.flip_h = true
