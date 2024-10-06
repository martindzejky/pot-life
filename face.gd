extends Node2D


enum Face {
    Happy = 0,
    Sad = 1
}


func setFace(face: Face):
    $sprite.frame = face
