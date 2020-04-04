extends Area2D

export var grabStarted = false
export var grabDuration = 0.5

var grabbedItem
var grabTarget


func _process(delta):
	
	# отслеживать пересечённые области в режиме захвата
	if grabStarted:
		var overlappingAreas = get_overlapping_areas()
		
		for area in overlappingAreas:
			if area.is_in_group("item_grab_area") and area.get_parent() == grabTarget:
				grab_item()


# начать захват 
func start_grab(targetItem):
	if targetItem.is_in_group("item"):
		grabStarted = true
		
		grabTarget = targetItem
		
		$AnimationPlayer.play("GrabStart")
		$Tween.interpolate_property(self, "position", grabTarget.position, 
				grabTarget.position - $GrabPoint.position + get_node(str(grabTarget.get_path()) + "/GrabPoint"), 
				grabDuration, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
		$Tween.start()


# отпустить предмет
func drop_item():
	if grabbedItem != null and grabbedItem.is_in_group("item"):
		$AnimationPlayer.play("DropItem")
		
		grabbedItem.isGrabbed = false
		grabbedItem.grabberGrabPoint = null


# схватить предмет
func grab_item():
	$AnimationPlayer.play("Idle")
	
	grabbedItem = grabTarget
	grabTarget = null
	
	grabbedItem.isGrabbed = true
	grabbedItem.grabberGrabPoint = $GrabPoint
	
	grabStarted = false
