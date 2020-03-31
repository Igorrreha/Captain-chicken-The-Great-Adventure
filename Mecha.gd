extends Area2D

export var tag = ""
export var activateAnimation = ""
export var deactivateAnimation = ""
export var isToogleable = false
export var defaultIsActive = false
var isActive


func _ready():
	isActive = defaultIsActive
	
	$AnimatedSprite.play("active" if isActive else "unactive")


# переклюение флага активности
func toogle_active():
	
	isActive = not isActive
	
	emit_signal("mecha_state_changed", isActive, tag)
	
	$AnimatedSprite.play("active" if isActive else "unactive")

