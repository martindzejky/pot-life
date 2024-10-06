extends Node2D
class_name Face


enum State {
    HAPPY = 0,
    SAD = 1,
    STRAINING = 2,
}


func setFace(face: State):
    $sprite.frame = face
