extends Node2D
class_name Creature

@export var bounds: CollisionShape2D
@export var skull: PackedScene
@export var wanderSpeed := 14.0
@export var wanderRange := 40.0
@export var huntingSpeed := 18.0
@export var evil := false


# primitive state machine
# idle, wandering

var state := ''
var wanderTarget := global_position
var huntingTarget: Node2D = null
var beingEatenBy: Node2D = null


func _ready():
    $hunger.value = randf_range(60, 200)
    switchState('idle')

func _process(delta):
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
    var object := skull.instantiate()
    get_parent().add_child(object)
    object.global_position = global_position



# idle

func idleStart(_prev):

    if $hunger.value > 100 and randf() < 0.1:
        switchState('birthing')
        $hunger.value -= 30
        return

    if evil and $hunger.value < 100 and randf() < 0.3:
        switchState('hunting')
        return

    $animation.play('idle')
    $"idle-timer".start(randf_range(1, 4))

    if $hunger.value < 20:
        $"big/face-offset/face/sprite/animation".play('sad')
    else:
        $"big/face-offset/face/sprite/animation".play('happy')

func idleProcess(_delta):
    if not $quik.playing and randf() < 0.001:
        $quik.play()

func idleTimeout():
    switchState('wandering')

func idleEnd(_next):
    $"idle-timer".stop()


# wandering

func wanderingStart(_prev):
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

    if not $quik.playing and randf() < 0.002:
        $quik.play()


# birthing

func birthingStart(_prev):

    $animation.play('idle')
    $"big/face-offset/face/sprite/animation".play('struggling')
    $"birthing-timer".start(randf_range(6, 12))

func birthingProcess(_delta):
    if not $quik.playing and randf() < 0.02:
        $quik.play()

func birthingTimeout():
    get_tree().get_first_node_in_group('spawner').spawnEggFromCreature(self)
    $birth.play()
    switchState('idle')

func birthingEnd(_next):
    $"birthing-timer".stop()


# hunting

func huntingStart(_prev):

    var targets := get_tree().get_nodes_in_group('creature').filter(func(creature): return not creature.evil)
    if targets.size() <= 0:
        switchState('idle')
        return

    var closestTarget := targets[0] as Node2D
    var closestDistance := closestTarget.global_position.distance_squared_to(global_position)

    for t in targets:
        var distance = t.global_position.distance_squared_to(global_position)
        if distance < closestDistance:
            closestDistance = distance
            closestTarget = t

    huntingTarget = closestTarget

    $animation.play('walk')
    $"big/face-offset/face/sprite/animation".play('evil')

func huntingProcess(delta):

    if huntingTarget == null:
        switchState('idle')
        return

    var movement = global_position.direction_to(huntingTarget.global_position) * huntingSpeed * delta
    var distance = global_position.distance_squared_to(huntingTarget.global_position)

    if distance > 80.0:
        global_position += movement
    else:
        switchState('eating')
        if huntingTarget is Creature:
            huntingTarget.beingEatenBy = self
            huntingTarget.switchState('beingEaten')

    if abs(movement.x) > 0.0001:
        $big.scale.x = sign(movement.x)

    if not $quik.playing and randf() < 0.002:
        $quik.play()

func huntingEnd(next):
    if next == 'eating': return

    if huntingTarget != null:
        if huntingTarget is Creature:
            huntingTarget.beingEatenBy = null
        huntingTarget = null


# eating

func eatingStart(_prev):
    $animation.play('idle')
    $"big/face-offset/face/sprite/animation".play('eating-evil')

func eatingProcess(delta):

    if huntingTarget == null:
        switchState('idle')
        return

    var otherHunger := huntingTarget.get_node_or_null('hunger') as Hunger

    if otherHunger == null:
        switchState('idle')
        return

    otherHunger.value -= delta * 4
    $hunger.value += delta * 4

func beingEatenStart(_prev):
    $animation.play('idle')
    $"big/face-offset/face/sprite/animation".play('struggling')

func beingEatenProcess(_delta):
    if beingEatenBy == null:
        switchState('idle')
