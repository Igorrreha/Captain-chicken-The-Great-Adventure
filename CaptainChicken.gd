extends KinematicBody2D

export var GRAV = 10

enum STATE {IDLE, RUN, JUMP, JUMPING, FALL, LANDING, ON_LADDER, IN_ACTION}
var state = STATE.IDLE

export var moveVec = Vector2(0, 0)
export var jumpForce = 150
export var runSpeed = 50
export var runAcc = 10
export var runDec = 10
export var ladderClimbSpeed = 30

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
			moveVec.y += GRAV
	
	move_and_slide(moveVec, Vector2(0, -1))
	
	set_state()

func _input(event):
	
	# прыжок / спрыгивание с лестницы
	if event.is_action_pressed("jump"):
		if is_on_floor() or state == STATE.ON_LADDER:
			moveVec.y -= jumpForce
			
			state = STATE.JUMP
	
	# действие
	if event.is_action_pressed("action"):
		var overlappingAreas = $ActionArea.get_overlapping_areas()
		

func set_state():
	if state != STATE.ON_LADDER and state != STATE.IN_ACTION:
		if is_on_floor():
			if moveVec.y < 0:
				state = STATE.JUMPING
			elif moveVec.y > GRAV:
				state = STATE.LANDING
				moveVec.y = 0
			elif moveVec.x == 0:
				state = STATE.IDLE
			else:
				state = STATE.RUN
		else: 
			if moveVec.y > 0:
				state = STATE.JUMP
			else:
				state = STATE.FALL
