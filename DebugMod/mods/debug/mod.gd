extends Node

const DebugSaveManager := preload("res://mods/debug/debug_save_manager.gd")

func _init ():
    SaveManager.set_script(DebugSaveManager)
