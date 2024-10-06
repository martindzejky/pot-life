extends Node2D
class_name Grass

@export var minScale := 1.0
@export var maxScale := 2.0

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

func die():

    queue_free()

    # need to move the death sound to the parent so it is not destroyed with the grass
    var sound := $death as AudioStreamPlayer2D
    remove_child(sound)
    get_parent().add_child(sound)
    sound.global_position = global_position
    sound.play()
    # should self-destruct once done playing


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
