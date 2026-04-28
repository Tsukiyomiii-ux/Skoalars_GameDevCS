extends Node2D

# These names must match your Scene Tree exactly!
@onready var item_container = $objective_scroll/itemcontainer
@onready var basket_label = $basket/basketlabel

var fruit_list = ["Apples", "Oranges", "Bananas", "Grapes", "Watermelon", "Carrots"]

func _ready():
	generate_shopping_list()

func generate_shopping_list():
	var total_items_needed = 0
	
	# Clear old labels
	for child in item_container.get_children():
		child.queue_free()
	
	# Pick random number of fruit types
	var tasks_count = randi_range(2, 4)
	fruit_list.shuffle()
	
	for i in range(tasks_count):
		var amount = randi_range(1, 5) 
		total_items_needed += amount # Add to the sum
		
		var fruit_name = fruit_list[i]
		var new_label = Label.new()
		new_label.text = str(amount) + "x " + fruit_name
		item_container.add_child(new_label)
	
	# Update the number on the plate
	basket_label.text = "0 / " + str(total_items_needed)
