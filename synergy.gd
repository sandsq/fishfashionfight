extends Area2D

var synergy_data = {}
var synergy_condition: Callable = func(data): 
		print("the synergy condition is using this data %s" % data)
		return true
var attached_to = null
var edge_info = null
