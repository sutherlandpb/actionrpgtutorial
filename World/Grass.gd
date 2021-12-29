extends Node2D
const GrassEffect = preload("res://Effects/GrassEffect.tscn")

func createGrassEffect():
	var grassEffect = GrassEffect.instance()
	var world = get_tree().current_scene
	world.add_child(grassEffect)
	grassEffect.global_position = global_position
	queue_free()


func _on_HurtBox_area_entered(area):
	createGrassEffect()
	queue_free()
