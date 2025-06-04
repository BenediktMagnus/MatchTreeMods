extends Node

func _enter_tree ():
    get_parent().on_scene_loaded.connect(_on_scene_loaded)

func _exit_tree ():
    get_parent().on_scene_loaded.disconnect(_on_scene_loaded)

func _on_scene_loaded (scene_root: Node):
    if scene_root.scene_file_path == "res://Characters/dwarf/Puppet_Gnome.tscn":
        _on_gnome_loaded(scene_root)

func _on_gnome_loaded (gnome_scene: Node2D):
    gnome_scene.get_node("BodyParts/HeadAnchor/HeadNormal/EyeBase").visible = false
    gnome_scene.get_node("BodyParts/HeadAnchor/HeadConfused/EyeBase").visible = false
    gnome_scene.get_node("BodyParts/HeadAnchor/HeadSus/EyeBase").visible = false
