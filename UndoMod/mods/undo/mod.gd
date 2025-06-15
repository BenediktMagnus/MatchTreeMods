extends Node

@export var reset_controller_scene: PackedScene

func _enter_tree ():
    get_parent().level_loaded.connect(_on_level_loaded)

func _exit_tree ():
    get_parent().level_loaded.disconnect(_on_level_loaded)

func _on_level_loaded (level: Node2D):
    var reset_controller := reset_controller_scene.instantiate()
    level.add_child(reset_controller)
