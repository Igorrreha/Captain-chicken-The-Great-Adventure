extends KinematicBody2D

export var isGrabbed = false

var grabberGrabPoint
var moveVec = Vector2(0, 0)
var moveDec = 10

func _process(delta):
	
	if isGrabbed:
		
		# поворот в сторону (!!!)
		rotation_degrees = 30 - (grabberGrabPoint.rotation_degrees if grabberGrabPoint.isHoldAngleRelativeToGlobalAxis else 0)
		
		# плавная трансляция положения в точку захвата
		$Tween.interpolate_property(self, "position", position, grabberGrabPoint.position, 0.3, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
		$Tween.start()
		
	else:
		
		# снижение горизонтальной скорости брошенного предмета
		if moveVec.x != 0:
			if (abs(moveVec.x) - moveDec) > 0:
				moveVec.x += moveDec if moveVec.x < 0 else -moveDec
			else:
				moveVec.x = 0
		
		# добавление гравитации
		moveVec.y += Global.GRAVITY.length()
		
		# перемещение
		move_and_slide(moveVec, Global.GRAVITY.normalized())

