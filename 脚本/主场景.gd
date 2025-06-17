extends Node2D

@onready var 物品提示面板 = preload("res://场景/物品提示框.tscn").instantiate()

func _ready():
	add_child(物品提示面板)
	物品提示面板.隐藏提示()

func _on_物品_鼠标进入物品(物品数据):
	物品提示面板.显示物品信息(物品数据)
	# 更新位置
	var 鼠标位置 = get_global_mouse_position()
	物品提示面板.global_position = 鼠标位置 + Vector2(20, 20)

func _on_物品_鼠标离开物品():
	物品提示面板.隐藏提示()
