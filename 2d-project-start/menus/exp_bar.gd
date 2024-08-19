extends ProgressBar
# Function to set the tooltip on hover

var level:int = 0

func _ready():
	# Enable the use of the custom tooltip
	self.tooltip_text = ""

func _gui_input(event: InputEvent):
	if event is InputEventMouseMotion:
		# Update tooltip text to show current value and max value
		tooltip_text = "Level: "+str(level) +"\n" + str(value) + " / " + str(max_value)
