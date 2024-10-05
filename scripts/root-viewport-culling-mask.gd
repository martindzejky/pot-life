extends Node

func _ready():
    get_tree().root.get_viewport().canvas_cull_mask = 3
