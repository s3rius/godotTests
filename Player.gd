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

func _physics_process(delta):
	var velocity = Vector2()
	
	if Input.is_action_pressed("ui_up") :
		velocity.y -= 1

	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
		
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1

	if Input.is_action_pressed("ui_right"):
		velocity.x += 1

	if velocity.length() > 0 :
		$Animation.playback_speed = 1
		if Input.is_action_pressed("ui_shift"):
			if stamina <= 0:
				velocity = velocity.normalized() * WALK_SPEED
				stamina = 0
			else :
				$Animation.playback_speed = 1.5
				velocity = velocity.normalized() * RUN_SPEED
				stamina -= STAMINA_CONSUMP * delta
		else :
			velocity = velocity.normalized() * WALK_SPEED
			stamina += (STAMINA_CONSUMP / 2) * delta
		if velocity.x > 0 :
			$Animation.current_animation = "right"
		elif velocity.x < 0 :
			$Animation.current_animation = "left"
		if velocity.y > 0 :
			$Animation.current_animation = "down"
		elif velocity.y < 0 :
			$Animation.current_animation = "up"
	else :
		$Animation.current_animation = "idle"
		$Animation.playback_speed = 0.5
		stamina += STAMINA_CONSUMP * delta
	stamina = clamp(stamina, 0, MAX_STAMINA)
	emit_signal("stamina_changed", stamina)
	move_and_collide(velocity * delta)
	