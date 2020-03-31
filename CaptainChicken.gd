extends KinematicBody2D

enum STATE {IDLE, RUN, JUMP, JUMPING, FALL, LANDING, ON_LADDER, IN_ACTION}
var state = STATE.IDLE

export var moveVec = Vector2(0, 0)
export var jumpForce = 150
export var runSpeed = 50
export var runAcc = 10
export var runDec = 10
export var ladderClimbSpeed = 30

var berserkerModeOn = false

var maxLandingSpeed = 300

export var hp = 100


signal hero_dead


func _ready():
	state = set_state()


func _process(delta):
	
	# перемещение
	var inpVec = Vector2()
	
	if Input.is_action_pressed("left"):
		inpVec.x -= 1;
	if Input.is_action_pressed("right"):
		inpVec.x += 1;
	
	# лестница
	if state != STATE.IN_ACTION:
		if state != STATE.ON_LADDER:
			# запрыгивание на лестницу
			if Input.is_action_pressed("up") or Input.is_action_pressed("down"):
				var overlappingAreas = $LadderCollisionArea.get_overlapping_areas()
				for area in overlappingAreas:
					if area.is_in_group("ladder"):
						moveVec = Vector2(0, 0)
						state = STATE.ON_LADDER
						$AnimationPlayer.play("LadderClimb")
		else:
			
			# проверяем, пересекает ли персонаж лестницу
			var overlappingAreas = $LadderCollisionArea.get_overlapping_areas()
			var isLadderOverlapped = false
			for area in overlappingAreas:
				if area.is_in_group("ladder"):
					isLadderOverlapped = true
			
			# перемещение по лестнице
			if Input.is_action_pressed("up"):
				inpVec.y -= 1
			if Input.is_action_pressed("down"):
				inpVec.y += 1
			moveVec.y = inpVec.y * ladderClimbSpeed
			
			# спрыгивание с лестницы
			if (isLadderOverlapped and is_on_floor() and not Input.is_action_pressed("up")) or not isLadderOverlapped:
				state = STATE.IDLE
	
	
	# отражение по x
	if state != STATE.IN_ACTION:
		if inpVec.x > 0:
			$Sprite.set_flip_h(false)
		elif inpVec.x < 0:
			$Sprite.set_flip_h(true)
	
	
	# перемещение в режиме берсерка
	if berserkerModeOn:
		state = STATE.RUN
		
		moveVec.x = runSpeed * (-1.75 if $Sprite.is_flipped_h() else 1.75)
		
		# гравитация
		if not is_on_floor():
			moveVec.y += Global.GRAVITY.length()
	
	# обычное перемещение
	else:
		if state != STATE.ON_LADDER and state != STATE.IN_ACTION:
			# бег
			if inpVec.x == 0:
				if moveVec.x != 0:
					moveVec.x += (runDec if moveVec.x < 0 else -runDec)
			elif abs(moveVec.x + (inpVec.x * runAcc)) > runSpeed:
				moveVec.x = runSpeed if inpVec.x > 0 else -runSpeed
			else: 
				moveVec.x += inpVec.x * runAcc
			
			# гравитация
			if not is_on_floor():
				moveVec.y += Global.GRAVITY.length()
	
	move_and_slide(moveVec, Global.GRAVITY.normalized())
	
	set_state()
	set_animation()


func _input(event):
	
	# прыжок / спрыгивание с лестницы
	if event.is_action_pressed("jump"):
		if (is_on_floor() or state == STATE.ON_LADDER) and state != STATE.IN_ACTION:
			moveVec.y -= jumpForce
			
			state = STATE.JUMP
	
	# действие
	if event.is_action_pressed("action") and state != STATE.IN_ACTION  and state != STATE.ON_LADDER and not berserkerModeOn:
		
		var overlappingAreas = $ActionArea.get_overlapping_areas()
		for area in overlappingAreas:
			
			if area.is_in_group("mecha"):
				if area.isActive == area.defaultIsActive or area.isToogleable:
					state = STATE.IN_ACTION
					moveVec = Vector2(0, 0)
					$Sprite.set_flip_h(true if area.scale.x > 0 else false)
					
					# включение анимации действия
					var actionAnimationName = (area.deactivateAnimation if area.isActive else area.activateAnimation)
					$AnimationPlayer.play("action_" + actionAnimationName)
					
					# таймер активации/деактивации механизма
					var timeToActionStart = get_time_to_action_start(actionAnimationName)
					var timer = get_node(str(area.get_path()) + "/ToogleTimer")
					timer.set_wait_time(timeToActionStart)
					timer.start()
					
					# позиционирование в точку действия
					var newPos = area.position + get_node(str(area.get_path()) + "/ActionPos").position * area.scale
					var tween = $Tween
					tween.interpolate_property(self, "position",
						position, newPos, timeToActionStart,
						Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					tween.start()
					
					break


# изменение состояния исходя из вектора движения и текущего положения в пространстве
func set_state():
	if state != STATE.ON_LADDER and state != STATE.IN_ACTION:
		if is_on_floor():
			if moveVec.y < 0:
				jump_start()
			elif moveVec.y > Global.GRAVITY.length():
				landing()
				if moveVec.y > maxLandingSpeed:
					hit(100)
				
				moveVec.y = 0
				
			if moveVec.x == 0:
				state = STATE.IDLE
			else:
				state = STATE.RUN
		else: 
			if moveVec.y > 0:
				state = STATE.FALL
			else:
				state = STATE.JUMP


# начало прыжка
func jump_start():
	pass
# приземление
func landing():
	pass

# проигрывание анимации
func set_animation():
	if state == STATE.IDLE:
		$AnimationPlayer.play("Idle")
	elif state == STATE.RUN:
		$AnimationPlayer.play("Run")
	elif state == STATE.JUMP:
		$AnimationPlayer.play("Jump")
	elif state == STATE.FALL:
		$AnimationPlayer.play("Fall")
	elif state == STATE.ON_LADDER:
		if moveVec.y == 0:
			$AnimationPlayer.stop()
			$AnimationPlayer.current_animation = "LadderClimb"
		elif moveVec.y < 0:
			$AnimationPlayer.play("LadderClimb")
		elif moveVec.y > 0:
			$AnimationPlayer.play_backwards("LadderClimb")


# получить промежуток времени от момента начала анимации взаимодействия с механизмом до момента применения этого действия
func get_time_to_action_start(animationName):
	match animationName:
		"buttonPress": 
			return 0.4
		"flyKick":
			return 0.8
		"":
			return 0.0


# обработка окончания анимации
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name.find("action_") != -1:
		$AnimationPlayer.play("Idle")
		state = STATE.IDLE


# получение урона
func hit(damage):
	hp -= damage
	
	if hp <= 0:
		berserkerModeOn = true
		$BerserkerModeTimer.start()


# смерть
func death():
	queue_free()
	
	emit_signal("hero_dead")
