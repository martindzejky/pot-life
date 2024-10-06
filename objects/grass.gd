extends Node2D
class_name Grass

@export var minScale := 1.0
@export var maxScale := 2.0
@export var bounds: CollisionShape2D

var initialScale := 1.0

# primitive state machine

var state := ''
var beingEatenBy: Node2D = null
var beingHealedBy: Node2D = null


func _ready():

    if randf() < 0.5:
        $scale/sprite.flip_h = true

    $energy.value = randf_range(10, 20)
    initialScale = randf_range(minScale, maxScale)

    $scale.scale = Vector2(1, 1) * initialScale
    $scale/sprite.frame = randi_range(0, $scale/sprite.hframes - 1)

    switchState('idle')

func _process(delta):

    var previousScale = $scale.scale.x
    var newScale := initialScale + floorf($energy.value / 30.0) / 4.0
    if newScale > previousScale + 0.1:
        $upgrade.play()
        if randf() < 0.2:
            $energy.value -= 20
            reproduce()

    $scale.scale = Vector2(1, 1) * newScale

    call(state + 'Process', delta)


func switchState(newState: String):

    if newState == state: return

    if has_method(state + 'End'):
        call(state + 'End', newState)

    var previousState := state
    state = newState

    if has_method(state + 'Start'):
        call(state + 'Start', previousState)

func hurtByFire():
    $energy.value -= 25
    switchState('hurt')

func die():

    queue_free()

    # need to move the death sound to the parent so it is not destroyed with the grass
    var sound := $death as AudioStreamPlayer2D
    remove_child(sound)
    get_parent().add_child(sound)
    sound.global_position = global_position
    sound.play()
    # should self-destruct once done playing


func reproduce():
    var copy := duplicate()

    var newPosition = global_position + (Vector2.RIGHT * randf_range(40, 80)).rotated(randf() * PI * 2)

    var rect := bounds.shape.get_rect()

    newPosition.x = clamp(
        newPosition.x,
        rect.position.x + bounds.global_position.x,
        rect.end.x + bounds.global_position.x
    )
    newPosition.y = clamp(
        newPosition.y,
        rect.position.y + bounds.global_position.y,
        rect.end.y + bounds.global_position.y
    )

    get_parent().add_child(copy)
    copy.global_position = newPosition


# idle

func idleStart(_prev):
    $"idle-timer".start(randf_range(1, 8))

func idleProcess(_delta):
    pass

func idleTimeout():
    $animation.play('sway')
    $"idle-timer".start(randf_range(1, 8))

func idleEnd(_next):
    $"idle-timer".stop()

# being eaten

func beingEatenStart(_prev):
    $animation.play('being-eaten')

func beingEatenProcess(_delta):
    if not is_instance_valid(beingEatenBy):
        beingEatenBy = null
        switchState('idle')

func beingEatenEnd(_next):
    $animation.play('RESET')


# being healed

func beingHealedStart(_prev):
    $animation.play('being-healed')

func beingHealedProcess(_delta):
    if not is_instance_valid(beingHealedBy):
        beingHealedBy = null
        switchState('idle')

func beingHealedEnd(_next):
    $animation.play('RESET')


# hurt

func hurtStart(_prev):
    $animation.play('being-eaten') # ehm... reused! end-of-compo stuff...
    $"hurt-timer".start(0.4)

func hurtProcess(_delta):
    pass

func hurtTimeout():
    switchState('idle')

func hurtEnd(_next):
    $"hurt-timer".stop()
