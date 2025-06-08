extends Node

const DebugSaveManager := preload("res://mods/debugMod/debug_save_manager.gd")

var loaded_world_map: Node2D = null
var loaded_level: Node2D = null

func _init ():
    SaveManager.set_script(DebugSaveManager)

func _enter_tree ():
    var modding_api: Node = get_parent() # Actually the ModdingApi class

    modding_api.world_map_loaded.connect(_on_world_map_loaded)
    modding_api.level_loaded.connect(_level_loaded)

func _input (event: InputEvent):
    if event.is_action_pressed("cheats"):
        if loaded_world_map != null:
            loaded_world_map.cheat_levels_button.visible = not loaded_world_map.cheat_levels_button.visible
            loaded_world_map.cup_win_mod_button.visible = not loaded_world_map.cup_win_mod_button.visible
        elif loaded_level != null:
            loaded_level.hud.win_level_btn.visible = not loaded_level.hud.win_level_btn.visible

func _on_world_map_loaded (world_map: Node2D):
    loaded_world_map = world_map

func _level_loaded (level: Node2D):
    loaded_level = level
