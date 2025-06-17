extends Control
class_name 格子类

signal 点击事件(格子: 格子类)
signal 悬停事件(格子: 格子类)
signal 离开事件(格子: 格子类)

signal 显示提示请求(物品数据, 位置)
signal 隐藏提示请求

enum 格子状态枚举{
				空闲,
				占用,
				盘旋,
				冲突
				}
var _当前状态: 格子状态枚举 = 格子状态枚举.空闲
var _索引: int
var _所属仓库: 仓库容器类

var _存储物品: 物品类 = null
var _本地列偏移: int
var _本地行偏移: int
var _关联格子组: Array[格子类]

@export var 空闲颜色: Color
@export var 占用颜色: Color
@export var 盘旋颜色: Color
@export var 冲突颜色: Color


@onready var _背景: ColorRect = $边框/背景

@onready var _悬停计时器: Timer = $Timer
var _悬停中: bool = false



func _ready() -> void:
	self.custom_minimum_size = Vector2(32 , 32)
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	_更新格子状态(格子状态枚举.空闲)
	mouse_entered.connect(_on_鼠标进入)
	mouse_exited.connect(_on_鼠标退出)
	gui_input.connect(_on_鼠标点击) # 确保点击在格子内才触发
	_悬停计时器.timeout.connect(_悬停超时)
	
func _on_鼠标点击(event: InputEvent) -> void: # 无需手动检测鼠标位置，gui_input 已自动过滤
	if event.is_action_pressed("快速转移") and _存储物品:
		_所属仓库.快速移动物品(_存储物品)
	elif event.is_action_pressed("左键点击"): 
		#$AudioStreamPlayer.play()
		点击事件.emit(self)
	elif event.is_action_pressed("右键点击") and _存储物品:
		_所属仓库.装备物品(_存储物品)
		
func _on_鼠标进入() -> void:
	悬停事件.emit(self)
	if _存储物品:
		_悬停中 = true
		_悬停计时器.start()
		
	
	
func _on_鼠标退出() -> void:
	离开事件.emit(self)
	_悬停计时器.stop()
	
	_悬停中 = false
	隐藏提示请求.emit()
	
func _悬停超时() -> void:
	if _悬停中 and _存储物品:
		# 通过信号传递物品数据
		显示提示请求.emit(_存储物品._物品数据, get_global_mouse_position())
	
func _更新格子状态(状态) -> void:
	match 状态:
		格子状态枚举.空闲:
			_当前状态 = 格子状态枚举.空闲
			_背景.color = 空闲颜色
		格子状态枚举.占用:
			_当前状态 = 格子状态枚举.占用
			_背景.color = 占用颜色
		格子状态枚举.盘旋:
			_当前状态 = 格子状态枚举.盘旋
			_背景.color = 盘旋颜色
		格子状态枚举.冲突:
			_当前状态 = 格子状态枚举.冲突
			_背景.color = 冲突颜色


##=======================
##  工厂方法
##=======================
static var 格子场景: PackedScene = preload("res://场景/格子.tscn")

static func 创建格子(索引: int, 仓库容器: 仓库容器类) -> 格子类:
	var 新格子 = 格子场景.instantiate()
	新格子._索引 = 索引
	新格子._当前状态 = 格子状态枚举.空闲
	新格子._所属仓库 = 仓库容器
	return 新格子
	
##=======================
##  公开接口
##=======================
## 获取格子属性
func 格子空闲中() -> bool: 
	return _存储物品 == null
func 获取索引() -> int: 
	return _索引
func 获取物品() -> 物品类: 
	return _存储物品
func 获取偏移() -> Vector2i: 
	return Vector2i(_本地列偏移, _本地行偏移)


### 格子操作
func 占用格子(物品: 物品类, 偏移: Vector2i, 关联格子组: Array[格子类]) -> void:
	_存储物品 = 物品
	_本地列偏移 = 偏移.x
	_本地行偏移 = 偏移.y
	_关联格子组 = 关联格子组
	_更新格子状态(格子状态枚举.占用)
#
func 清空格子() -> void:
	_存储物品 = null
	_更新格子状态(格子状态枚举.空闲)
#
func 更新基础状态() -> void:
	if 格子空闲中():
		_更新格子状态(格子状态枚举.空闲)
	else:
		_更新格子状态(格子状态枚举.占用)
#
func 更新交互状态(冲突: bool) -> void:
	if 冲突:
		_更新格子状态(格子状态枚举.冲突)
	else:
		_更新格子状态(格子状态枚举.盘旋)
