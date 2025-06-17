extends Control
class_name 物品类

enum 物品状态枚举{
				静置,
				拖拽中
				}
				
var _当前状态: 物品状态枚举 = 物品状态枚举.静置
var _物品数据: 物品资源类
var _偏移量: Vector2 = Vector2.ZERO

var _原始主格子: 格子类 = null
var _原始占用格子列表: Array[格子类] = []

@onready var _图片: TextureRect = $图片



func _ready() -> void:
	_图片.texture = _物品数据.物品纹理
	self.size = Vector2(全局设置.格子边长 * _物品数据.列数 , 全局设置.格子边长 * _物品数据.行数)
func _process(_delta: float) -> void:
	if _当前状态 == 物品状态枚举.拖拽中:
		global_position = get_global_mouse_position() - _偏移量
		
		
		
func _计算偏移量(居中模式: bool) -> void:
	if 居中模式:
		_偏移量 = Vector2(size.x / 2 , size.y / 2)
	else:
		if not is_inside_tree():
			_偏移量 = Vector2.ZERO
		_偏移量 = get_global_mouse_position() - global_position
		
	




##=======================
##  工厂方法
##=======================
static var 物品场景: PackedScene = preload("res://场景/物品.tscn")

static func 创建物品(数据: 物品资源类, 复制数据: bool = true) -> 物品类:
	var 新物品 = 物品场景.instantiate()
	if 复制数据:
		新物品._物品数据 = 数据.duplicate()
	else :
		新物品._物品数据 = 数据
	return 新物品

##=======================
##  公开接口
##=======================
## 获取物品属性
#=====Getter====
func 获取物品类型() -> 物品资源类.物品类型枚举:
	return _物品数据.物品类型
func 获取物品尺寸() -> Vector2i:
	return Vector2i(_物品数据.列数, _物品数据.行数)
	
func 获取原始主格子() -> 格子类:
	return _原始主格子
func 获取原始占用格子列表() -> Array[格子类]:
	return _原始占用格子列表
# ================
## 记录数据
func 记录原始位置(主格子: 格子类, 占用格子列表: Array[格子类]) -> void:
	_原始主格子 = 主格子
	_原始占用格子列表 = 占用格子列表.duplicate()
## 物品操作
func 开始拖拽物品(居中模式: bool = false) -> void:
	
	_当前状态 = 物品状态枚举.拖拽中
	_计算偏移量(居中模式)
func 停止拖拽物品() -> void:
	_当前状态 = 物品状态枚举.静置
