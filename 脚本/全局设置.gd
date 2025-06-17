extends Node

const 格子边长 : int = 32

var _正在拖动的物品: 物品类
var _拖动偏移量: Vector2i
var _拖动显示层: CanvasLayer
var _右键转移目标装备槽列表: Array[装备槽类] = []  # 初始化空数组
var _右键转移目标仓库列表: Array[仓库容器类] = []  # 初始化空数组






##=======================
##  工厂方法
##=======================
static func 隐藏鼠标() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
static func 显示鼠标() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

##=======================
##  公开接口
##=======================
## 获取方法 
#=====Getter====
func 获取_正在拖动的物品() -> 物品类: 
	return _正在拖动的物品
	
func 获取_拖动偏移量() -> Vector2i: 
	return _拖动偏移量
	
func 获取_拖动显示层() -> CanvasLayer:
	if not _拖动显示层: 
		_拖动显示层 = CanvasLayer.new()
		_拖动显示层.layer = 128  # 顶层显示
		get_tree().root.add_child(_拖动显示层)
	return _拖动显示层
# ================

## 开始拖动物品   定义开始拖动物品
func 开始拖拽物品(物品: 物品类, 偏移量: Vector2i, 强制位置: bool = false) -> void:
	_正在拖动的物品 = 物品
	_拖动偏移量 = 偏移量
	物品.开始拖拽物品(强制位置)
	
	var 物品的父节点 = 物品.get_parent()
	if 物品的父节点:
		物品.reparent(获取_拖动显示层())
	else:
		获取_拖动显示层().add_child(物品)
	隐藏鼠标()
## 停止拖动物品
func 停止拖拽物品() -> void:
	if _正在拖动的物品:
		_正在拖动的物品.停止拖拽物品()
		_正在拖动的物品 = null
	显示鼠标()
## 检查是否有物品正在被拖动
func 有正在拖动物品() -> bool: 
	return _正在拖动的物品 != null
	

#=====Getter====
## 添加装备槽
func 添加右键目标装备槽(装备槽: 装备槽类) -> void:
	_右键转移目标装备槽列表.append(装备槽)
	
## 尝试装备物品
func 穿戴装备(物品: 物品类, 来源背包: 仓库容器类) -> void:
	if 来源背包.is_背包:
		for 装备槽 in _右键转移目标装备槽列表:
			if 装备槽.添加物品(物品):
				来源背包.移除物品(物品)
				return
## 添加主背包
func 添加右键目标仓库(背包: 仓库容器类) -> void:
	_右键转移目标仓库列表.append(背包)

## 尝试卸下装备
func 卸下装备(物品: 物品类, 来源装备槽: 装备槽类) -> void:
	for 仓库 in _右键转移目标仓库列表:
		if 仓库.添加物品(物品):
			来源装备槽.移除物品(物品)
			return
