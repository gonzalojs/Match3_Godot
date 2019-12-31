extends Node2D

# It only needs to keep track of how much healt it has
export (int) var health


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func take_damage(damage):
	health -= damage
	# Can add damage effect here