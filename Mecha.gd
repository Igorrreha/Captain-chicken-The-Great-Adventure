extends Area2D

export var tag = ""
export var activateAnimation = ""
export var deactivateAnimation = ""
export var is_toogleable = false
export var default_is_active = false
var is_active


func _ready():
	is_active = default_is_active


# переклюение флага активности
func toogle_active():
	if is_active == default_is_active:
		is_active = not default_is_active
		
		emit_signal("mecha_state_changed", is_active, tag)
		
	elif is_toogleable:
		is_active = not default_is_active
		
		emit_signal("mecha_state_changed", is_active, tag)
