extends VBoxContainer

func update_data(data: Dictionary):
	for key in data.keys():
		if get_node(key):
			get_node(key).text = key + ": " + str(data[key])
		else:
			var node = Label.new()
			add_child(node)
			node.name = key
			node.text = key + ": " + str(data[key])
	
	for node in get_children():
		if not data.has(node.name):
			node.queue_free()
