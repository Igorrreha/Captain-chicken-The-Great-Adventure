extends Node2D

var Console
var Hero


func _ready():
	Console = $Conosle
	Hero = $Hero
	
	Hero.connect("hero_dead", self, "restart")


func _process(delta):
	
	# отображение информации в консоли (тест)
	if has_node("Hero"):
		Console.text = str(Hero.moveVec) + " " + str(Hero.state) + " " + str(Hero.is_on_floor()) + " " + str(Hero.hp)


# перезапуск уровня
func restart():
	get_tree().reload_current_scene()
