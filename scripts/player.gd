extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -250.0 

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var is_dead: bool = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if is_dead:
		return
	else:
		
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		var direction := Input.get_axis("move_left", "move_right")
		
		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jump")
		


		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		move_and_slide()
	
func die() -> void:
	if is_dead:
		return
		
	is_dead = true
	velocity = Vector2.ZERO # Para o movimento do jogador
	
	# Desativa a colisão com segurança (melhor do que queue_free)
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Toca a animação (verifique se o nome no AnimatedSprite2D é exatamente este)
	animated_sprite.play("death")
