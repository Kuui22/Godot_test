extends Resource
class_name Character



@export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75
# Jump acceleratio
@export var jump_impulse = 20
# read
@export var double_jump_counter = false
var health:int = 5
var defence:int = 0
@export var statsdict:Dictionary = {
	"Speed":speed,
	"Health":health,
	"Defence":defence
	}
	
var coins:int 
var diamonds:int
@export var valuesdict:Dictionary = {
	"Coins":coins,
	"Diamonds":diamonds
	}
