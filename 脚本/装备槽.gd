@tool
extends 仓库容器类
class_name 装备槽类


# 有效物品时的滤镜颜色
@export var 有效颜色: Color = Color.GREEN
# 无效物品时的滤镜颜色
@export var 无效颜色: Color = Color.RED
# 背景图片
@export var 背景图片: Texture2D


@onready var _背景图片: TextureRect = $背景图片
@onready var _筛选过滤: ColorRect = $筛选过滤


func _ready() -> void:
	super._ready()
	_背景图片.texture = 背景图片
	_筛选过滤.hide()
	
func _处理格子悬停(格子: 格子类, 是否悬停: bool) -> void:
	if 是否悬停:
		if 全局设置.有正在拖动物品():
			_筛选过滤.show()
			var 有冲突 = not _验证物品类型(全局设置.获取_正在拖动的物品())
			if not 有冲突:
				_筛选过滤.color = 有效颜色
			else :
				_筛选过滤.color = 无效颜色
	else :
		_筛选过滤.hide()
		
func _开始拖拽物品(来源格子: 格子类) -> void:
	super._开始拖拽物品(来源格子)
	# 拿起装备槽内的物品时，装备槽显示绿色（表示可以放回）
	_筛选过滤.show()
	_筛选过滤.color = 有效颜色

##=======================
##  公开接口
##=======================
## 装备操作卸下
func 装备物品(物品: 物品类) -> void:
	$AudioStreamPlayer.play()
	全局设置.卸下装备(物品, self)
func 移除物品(物品: 物品类, 保持悬停状态: bool = false) -> void:
	$AudioStreamPlayer.play()
	if _物品映射表.has(物品):
		# 清除所有格子的占用状态
		for 格子 in _全部格子:
			if 格子.获取物品() == 物品:
				格子.清空格子()
		
		_物品映射表.erase(物品)
		if is_instance_valid(物品) and 物品.get_parent() == _物品容器:
			_物品容器.remove_child(物品)
##=======================
##  更新公开接口辅助函数
##=======================
## 放置物品，更新格子状态
func _放置物品到格子(物品: 物品类, 可放置区域: Array[格子类]) -> void:
	$AudioStreamPlayer.play()
	# 0. 强制清除原有装备
	if not _物品映射表.is_empty():
		var 原有物品 = _物品映射表.keys()[0]  # 获取当前装备的唯一物品
		移除物品(原有物品)  # 清除原有装备
	# 1. 确保物品在正确的父节点下
	if not 物品.get_parent():
		_物品容器.add_child(物品)
	else:
		物品.reparent(_物品容器)
	# 2. 更新物品映射表（记录物品与主格子的关系）
	_物品映射表.clear()  # 先清空
	_物品映射表[物品] = 可放置区域[0]
	for 格子 in _全部格子:  # 遍历装备槽所有格子
		var 相对位置 = Vector2i(
			格子._索引 % 仓库列数 - 可放置区域[0]._索引 % 仓库列数,
			floor(格子._索引 / 仓库列数) - floor(可放置区域[0]._索引 / 仓库列数))
		格子.占用格子(物品, 相对位置, _全部格子)  # 全部格子都标记为此物品占用
	# 4. 设置物品位置（对齐中心）
	物品.global_position = Vector2(
		size.x / 2 + global_position.x - 物品.size.x / 2,
		size.y / 2 + global_position.y - 物品.size.y / 2
	)
	
func _获取携带物品占用格子列表(鼠标所在的格子: 格子类, 物品: 物品类, 偏移: Vector2i = Vector2i.ZERO, 
				   忽略占用: bool = false) -> Array[格子类]:
					
	if self is 装备槽类:
		# 只需要检查当前格子是否可用
		if 忽略占用 or 鼠标所在的格子.格子空闲中() or 鼠标所在的格子.获取物品() == 物品:
			return [鼠标所在的格子]
		return []
	var 物品尺寸 = 物品.获取物品尺寸()
	if 物品尺寸.x <= 0 or 物品尺寸.y <= 0:
		return []
	var 中心偏移列 = 物品尺寸.x / 2
	var 中心偏移行 = 物品尺寸.y / 2
	var 物品左上格子索引 = 鼠标所在的格子._索引 - (中心偏移列 + 中心偏移行 * 仓库列数)
	if 物品左上格子索引 < 0 or 物品左上格子索引 >= _全部格子.size():
		return []
		
	var 物品左上角格子所在的列 = 物品左上格子索引 % 仓库列数 # 取余
	var 物品左上角格子所在的行 = 物品左上格子索引 / 仓库列数 # 取整
	if 物品左上角格子所在的列 < 0 or 物品左上角格子所在的行 < 0:
		return []
	if 物品左上角格子所在的列 + 物品尺寸.x > 仓库列数 or 物品左上角格子所在的行 + 物品尺寸.y > 仓库行数:
		return []
		
	var 物品占用格子列表: Array[格子类] = []
	var 物品左上角格子所在行的开头格子索引 = 物品左上角格子所在的行 * 仓库列数
	for y in range(物品尺寸.y):
		var 物品每行开头格子的索引 = 物品左上角格子所在行的开头格子索引 + y * 仓库列数  # 遍历出整个物品每行的开头格子索引
		for x in range(物品尺寸.x): #for x in range(2) 会循环 2 次，每次将 x 的值依次赋为 0 和 1。
			var 物品所有格子的索引 = 物品每行开头格子的索引 + (物品左上角格子所在的列 + x)  # 只需做简单加法
			
			if 物品所有格子的索引 >= _全部格子.size():
				return []
				
			if not 忽略占用: # 如果启用占用检查
				if not _全部格子[物品所有格子的索引].格子空闲中() and _全部格子[物品所有格子的索引].获取物品() != 物品:
					return [] # 发现格子上有其他物品 返回空数组
			物品占用格子列表.append(_全部格子[物品所有格子的索引])
	return 物品占用格子列表
