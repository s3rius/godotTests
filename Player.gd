extends KinematicBody2D

signal stamina_changed(stmn)
export (int) var MAX_STAMINA
export (int) var STAMINA_CONSUMP
export (int) var WALK_SPEED
export (int) var RUN_SPEED
var screensize
var stamina

func _ready():
	stamina = MAX_STAMINA
	screensize = get_viewport_rect().size


func _process(delta):
	var velocity = _input()
	var is_sprinting = _check_sprinting()
	
	velocity = _proceed_stamina(velocity, is_sprinting, delta)
	_move(velocity, delta)
	
	_proceed_animation(velocity)
	

func _input():
	var velocity = Vector2()
	
	if Input.is_action_pressed("ui_up") :
		velocity.y -= 1

	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
		
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1

	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	
	return velocity
	

func _check_sprinting():
	if Input.is_action_pressed("ui_shift"):
		return true
	return false


func _proceed_stamina(velocity, is_sprinting, delta):
	if velocity.length() > 0 :
		if is_sprinting:
			if stamina <= 0:
				velocity = velocity.normalized() * WALK_SPEED
				stamina = 0
			else :
				velocity = velocity.normalized() * RUN_SPEED
				stamina -= STAMINA_CONSUMP * delta
		else :
			velocity = velocity.normalized() * WALK_SPEED
			stamina += (STAMINA_CONSUMP / 2) * delta
	else :
		stamina += STAMINA_CONSUMP * delta
		
	stamina = clamp(stamina, 0, MAX_STAMINA)
	emit_signal("stamina_changed", stamina)
	return velocity


func _move(velocity, delta):
	move_and_collide(velocity * delta)
	
	
func _proceed_animation(velocity):
	if velocity.length() > 0 :
		if velocity.x > 0 :
			$Animation.current_animation = "right"
		elif velocity.x < 0 :
			$Animation.current_animation = "left"
		elif velocity.y > 0 :
			$Animation.current_animation = "down"
		elif velocity.y < 0 :
			$Animation.current_animation = "up"
	else :
		$Animation.current_animation = "idle"
	