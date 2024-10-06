extends Node2D
class_name Creature

@export var bounds: CollisionShape2D
@export var skull: PackedScene
@export var wanderSpeed := 14.0
@export var wanderRange := 40.0
@export var huntingSpeed := 18.0
@export var healingSpeed := 18.0
@export var evil := false


# primitive state machine

var state := ''
var wanderTarget := global_position
var huntingTarget: Node2D = null
var healingTarget: Node2D = null
var beingEatenBy: Node2D = null


func _ready():
    $hunger.value = randf_range(30, 100)
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

    # need to move the death sound to the parent so it is not destroyed with the creature
    var sound := $death as AudioStreamPlayer2D
    remove_child(sound)
    get_parent().add_child(sound)
    sound.global_position = global_position
    sound.play()
    # should self-destruct once done playing


# idle

func idleStart(_prev):
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

    if $hunger.value > 100 and randf() < 0.1:
        switchState('birthing')
        $hunger.value -= 30

    elif evil and $hunger.value < 100 and randf() < 0.3:
        switchState('hunting')

    elif not evil and $hunger.value < 100 and randf() < 0.4:
        switchState('goingToHeal')

    else:
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
    var grasses := get_tree().get_nodes_in_group('grass')
    targets.append_array(grasses)

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

    if not is_instance_valid(huntingTarget):
        huntingTarget = null
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
        if huntingTarget is Grass:
            huntingTarget.beingEatenBy = self
            huntingTarget.switchState('beingEaten')

    if abs(movement.x) > 0.0001:
        $big.scale.x = sign(movement.x)

    if not $quik.playing and randf() < 0.002:
        $quik.play()

func huntingEnd(next):
    if next == 'eating': return

    if huntingTarget != null and is_instance_valid(huntingTarget):
        if huntingTarget is Creature:
            huntingTarget.beingEatenBy = null
        if huntingTarget is Grass:
            huntingTarget.beingEatenBy = null
        huntingTarget = null


# going to heal

func goingToHealStart(_prev):

    var targets := get_tree().get_nodes_in_group('grass')

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

    healingTarget = closestTarget

    $animation.play('walk')
    $"big/face-offset/face/sprite/animation".play('happy')

func goingToHealProcess(delta):

    if not is_instance_valid(healingTarget):
        healingTarget = null
        switchState('idle')
        return

    var movement = global_position.direction_to(healingTarget.global_position) * healingSpeed * delta
    var distance = global_position.distance_squared_to(healingTarget.global_position)

    if distance > 80.0:
        global_position += movement
    else:
        switchState('healing')
        if healingTarget is Grass:
            healingTarget.beingHealedBy = self
            healingTarget.switchState('beingHealed')

    if abs(movement.x) > 0.0001:
        $big.scale.x = sign(movement.x)

    if not $quik.playing and randf() < 0.002:
        $quik.play()

func goingToHealEnd(next):
    if next == 'healing': return

    if healingTarget != null and is_instance_valid(healingTarget):
        if healingTarget is Grass:
            healingTarget.beingHealedBy = null
        healingTarget = null


# eating

func eatingStart(_prev):
    $animation.play('idle')
    $"big/face-offset/face/sprite/animation".play('eating-evil')
    $"eating-timer".start(randf_range(10, 20))

func eatingProcess(delta):

    if not is_instance_valid(huntingTarget):
        huntingTarget = null
        switchState('idle')
        return

    var otherHunger := huntingTarget.get_node_or_null('hunger') as Hunger
    var otherEnergy := huntingTarget.get_node_or_null('energy') as Energy

    if otherHunger != null:
        otherHunger.value -= delta * 6
        $hunger.value += delta * 6
    elif otherEnergy != null:
        otherEnergy.value -= delta * 20
        $hunger.value += delta * 4
    else:
        switchState('idle')

func eatingTimeout():
    switchState('idle')

func eatingEnd(_next):
    if is_instance_valid(huntingTarget):
        if huntingTarget is Creature:
            huntingTarget.beingEatenBy = null
        if huntingTarget is Grass:
            huntingTarget.beingEatenBy = null
    huntingTarget = null
    $"eating-timer".stop()

func beingEatenStart(_prev):
    $animation.play('being-eaten')
    $"big/face-offset/face/sprite/animation".play('struggling')

func beingEatenProcess(_delta):
    if not is_instance_valid(beingEatenBy):
        beingEatenBy = null
        switchState('idle')


# healing

func healingStart(_prev):
    $animation.play('idle')
    $"big/face-offset/face/sprite/animation".play('healing')
    $"healing-timer".start(randf_range(10, 20))

func healingProcess(delta):

    if not is_instance_valid(healingTarget):
        healingTarget = null
        switchState('idle')
        return

    var otherEnergy := healingTarget.get_node_or_null('energy') as Energy

    if otherEnergy != null:
        otherEnergy.value += delta * 2
        $hunger.value += delta * 4
    else:
        switchState('idle')

func healingTimeout():
    switchState('idle')

func healingEnd(_next):
    if is_instance_valid(healingTarget):
        if healingTarget is Grass:
            healingTarget.beingHealedBy = null
    healingTarget = null
    $"healing-timer".stop()
