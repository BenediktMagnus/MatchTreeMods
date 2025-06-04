extends Node

@export var fixed_map001_script: Script

func _enter_tree ():
    get_parent().level_loaded.connect(_on_level_loaded)

func _exit_tree ():
    get_parent().level_loaded.disconnect(_on_level_loaded)

func _on_level_loaded (level: Node2D):
    if level.scene_file_path == "res://Levels/Map01/map001.tscn":
        await get_tree().process_frame # Wait for the level to be fully loaded
        level.CurrentDialog.OnDialogEnded.connect(_on_map001_dialog_ended.bind(level))

func _on_map001_dialog_ended (level: Node2D):
    level.RewardState = 3
