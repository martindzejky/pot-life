extends Node2D
class_name Creature

@export var bounds: CollisionShape2D
@export var skull: PackedScene
@export var wanderSpeed := 14.0
@export var wanderRange := 40.0
@export var evil := false


# primitive state machine
# idle, wandering

var state := ''
var wanderTarget := global_position


func _ready():
    switchState('idle')

func _process(delta):
    call(state + 'Process', delta)

func switchState(newState: String):

    if newState == state: return

    if has_method(state + 'End'):
        call(state + 'End')

    state = newState

    if has_method(state + 'Start'):
        call(state + 'Start')

func die():
    queue_free()
    var object := skull.instantiate()
    get_parent().add_child(object)
    object.global_position = global_position



# idle

func idleStart():

    if $hunger.value > 100 and randf() < 0.04:
        switchState('birthing')
        $hunger.value -= 30
        return

    $animation.play('idle')
    $"idle-timer".start(randf_range(1, 4))

    if $hunger.value < 20:
        $"big/face-offset/face/sprite/animation".play('sad')
    elif evil:
        $"big/face-offset/face/sprite/animation".play('evil')
    else:
        $"big/face-offset/face/sprite/animation".play('happy')

func idleProcess(_delta):
    pass

func idleTimeout():
    switchState('wandering')

func idleEnd():
    $"idle-timer".stop()


# wandering

func wanderingStart():
    $animation.play('walk')

    wanderTarget = global_position + Vector2(
        randf_range(-wanderRange, wanderRange),
        randf_range(-wanderRange, wanderRange)
    )

    var rect := bounds.shape.get_rect()

    wanderTarget.x = clamp(
        wanderTarget.x,
        rect.position.x + bounds.global_position.x,
        rect.end.x + bounds.global_position.x
    )
    wanderTarget.y = clamp(
        wanderTarget.y,
        rect.position.y + bounds.global_position.y,
        rect.end.y + bounds.global_position.y
    )


func wanderingProcess(delta):
    var movement = global_position.direction_to(wanderTarget) * wanderSpeed * delta
    var distance = global_position.distance_squared_to(wanderTarget)

    if distance > movement.length_squared():
        global_position += movement
    else:
        global_position = wanderTarget
        switchState('idle')

    if abs(movement.x) > 0.0001:
        $big.scale.x = sign(movement.x)


# birthing

func birthingStart():

    $animation.play('idle')
    $"big/face-offset/face/sprite/animation".play('struggling')
    $"birthing-timer".start(randf_range(6, 12))

func birthingProcess(_delta):
    pass

func birthingTimeout():
    get_tree().get_first_node_in_group('spawner').spawnEggFromCreature(self)
    switchState('idle')

func birthingEnd():
    $"birthing-timer".stop()
