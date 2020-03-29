extends Node2D

var Console
var Hero

func _ready():
	Console = $Conosle
	Hero = $Hero

func _process(delta):
	Console.text = str(Hero.moveVec) + " " + str(Hero.state) + " " + str(Hero.is_on_floor())
