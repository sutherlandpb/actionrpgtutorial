extends KinematicBody2D

export var ACCELERATION = 500
export var MAX_SPEED = 80
export var ROLL_SPEED = 125 
export var FRICTION = 500

enum {
	MOVE,
	ROLL,
	ATTACK
}
const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")
var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.LEFT
var stats = PlayerStats

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = $AnimationTree.get("parameters/playback")
onready var hitbox = $HitBoxPivot/SwordHitBox 
onready var hurtbox = $HurtBox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer

func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true
	$HitBoxPivot/SwordHitBox/CollisionShape2D.set_deferred("disabled", true)
	hitbox.knockback_vector = roll_vector
	
# Called every physics tick
func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)
	
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		hitbox.knockback_vector = roll_vector
		animationTree.set("parameters/idle/blend_position", input_vector)
		animationTree.set("parameters/run/blend_position", input_vector)
		animationTree.set("parameters/attack/blend_position", input_vector)
		animationTree.set("parameters/roll/blend_position", input_vector)
		animationState.travel("run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:		
		animationState.travel("idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	move()
	if Input.is_action_just_pressed("Attack"):
		state = ATTACK
	elif Input.is_action_just_pressed("Roll"):
		state = ROLL

func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("attack")
func roll_state(delta):
	velocity = roll_vector * ROLL_SPEED	
	animationState.travel("roll")
	move()
	
func move():
	velocity = move_and_slide(velocity)

func roll_animation_finish():
	state = MOVE
	velocity = velocity * 0.8	
	
func attack_animation_finish():
	state = MOVE

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(0.6)
	hurtbox.create_hit_effect()
	var playerHurtSound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSound)


func _on_HurtBox_invincibility_started():
	blinkAnimationPlayer.play("Start")


func _on_HurtBox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
