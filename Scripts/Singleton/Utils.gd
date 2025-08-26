extends Node

func shuffle_buttons(parent_node: Node) -> void:
	randomize()
	var buttons: Array = []

	for child in parent_node.get_children():
		if child is Button:
			buttons.append(child)

	buttons.shuffle()

	for button: Button in buttons:
		parent_node.move_child(button, parent_node.get_child_count() - 1)
