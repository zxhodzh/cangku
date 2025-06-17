@tool
extends ColorRect
class_name 仓库容器类

enum 物品操作模式枚举 {
					放置,
					拾取,
					快速移动,
					装备操作
					}
					
var _全部格子: Array[格子类] = []  # 所有格子实例
var _物品映射表: Dictionary[物品类, 格子类] = {}  # 物品到其左上角格子的映射   [键  值]
var _快速转移目标列表: Array[仓库容器类] = []

@export var is_背包: bool = false  # 导出到编辑器，可手动设置


@export var 仓库列数: int
@export var 仓库行数: int
@export var 实时预览大小: bool = true
@export var 允许存放的物品类型: Array[物品资源类.物品类型枚举]

@onready var _格子容器: GridContainer = $格子容器
@onready var _物品容器: Control = $物品容器



func _ready() -> void:
	if not Engine.is_editor_hint():
		_初始化库存格子()
		
	for 格子 in _全部格子:
		
		格子.显示提示请求.connect(_显示物品提示)
		格子.隐藏提示请求.connect(_隐藏物品提示)

func _显示物品提示(物品数据: 物品资源类, 位置: Vector2) -> void:
	# 获取UI中的物品提示框  测试场景
	var ui = owner as Control
	if ui and ui.has_node("物品提示框"):
		ui.物品提示框.显示物品信息(物品数据, 位置)
	

func _隐藏物品提示() -> void:
	var ui = owner as Control
	if ui and ui.has_node("物品提示框"):
		ui.物品提示框.隐藏提示()
func _process(delta: float) -> void:
	if 实时预览大小 and Engine.is_editor_hint():
		var 新尺寸 = Vector2(仓库列数 * 全局设置.格子边长, 仓库行数 * 全局设置.格子边长)
		if 新尺寸 != size:
			size = 新尺寸

func _初始化库存格子() -> void:
	_格子容器.columns = 仓库列数
	for 行 in range(仓库行数):
		for 列 in range(仓库列数):
			var 索引 = 行 * 仓库列数 + 列
			var 格子 = 格子类.创建格子(索引, self)
			_格子容器.add_child(格子)
			_全部格子.append(格子)
			# 信号连接
			格子.点击事件.connect(_处理格子点击)
			格子.悬停事件.connect(_处理格子悬停.bind(true))
			格子.离开事件.connect(_处理格子悬停.bind(false))
			




func _处理格子点击(格子: 格子类) -> void:
	if 全局设置.有正在拖动物品():
		_尝试放置物品(格子)    
	elif 格子.获取物品():
		_开始拖拽物品(格子)
func _处理格子悬停(格子: 格子类, 是否悬停: bool) -> void:
		
	
	
	if not 全局设置.有正在拖动物品():
		return
		
	var 携带物品 = 全局设置.获取_正在拖动的物品()
	
	
	var 覆盖格子 = _获取携带物品占用格子列表(格子, 携带物品, 全局设置.获取_拖动偏移量(), true)
	var 有冲突 = not _验证物品类型(携带物品)
	
	if not 有冲突:
		var 覆盖物品集合 = {}
		for 格 in 覆盖格子:
			if not 格.格子空闲中() and 格.获取物品() != 携带物品:
				覆盖物品集合[格.获取物品()] = true
		有冲突 = 覆盖物品集合.size() > 1 
		
	for 格 in 覆盖格子:
		if 是否悬停:
			格.更新交互状态(有冲突)
		else:
			格.更新基础状态()

func _尝试放置物品(鼠标所在的格子: 格子类) -> void:
	var 携带物品 = 全局设置.获取_正在拖动的物品()
	if not _验证物品类型(携带物品):
		return
		
	var 放置位置 = _获取携带物品占用格子列表(鼠标所在的格子, 携带物品, 全局设置.获取_拖动偏移量(), true)
	if 放置位置.is_empty():
		return
	# 收集目标区域内的所有不同物品
	var 原有物品集合 = {}
	for 格子 in 放置位置:
		if not 格子.格子空闲中() and 格子.获取物品() != 携带物品:
			原有物品集合[格子.获取物品()] = true
			
	# 放置/交换规则
	match 原有物品集合.size():
		0:  # 空位
			_放置物品到格子(携带物品, 放置位置)
			全局设置.停止拖拽物品()
		1:  # 单物品交换（即使部分重叠）
			var 原有物品 = 原有物品集合.keys()[0]
			移除物品(原有物品)
			_放置物品到格子(携带物品, 放置位置)
			全局设置.停止拖拽物品()
			全局设置.开始拖拽物品(原有物品, Vector2.ZERO, true)
		_:  # >=2个物品，不处理（保持红色状态）
			pass
			
			
func _开始拖拽物品(来源格子: 格子类) -> void:
	var 物品 = 来源格子.获取物品()
	全局设置.开始拖拽物品(物品, Vector2i.ZERO, true)
	移除物品(物品, true)
	
#2

	
func _验证物品类型(物品: 物品类) -> bool:
	if 允许存放的物品类型.has(物品资源类.物品类型枚举.全部):
		return true    # 如果 允许存放的物品类型 包含 "全部"类型，直接通过验证 返回true
	return 允许存放的物品类型.has(物品.获取物品类型())

##=======================
##  公开接口
##=======================
## 物品管理
func 获取全部格子() -> Array[格子类]: 
	return _全部格子

func 添加物品(物品: 物品类) -> bool: 
	$AudioStreamPlayer.play()      #添加物品逻辑
	if not _验证物品类型(物品):                       #如果 _验证物品类型(物品) 方法返回假 即验证不通过,
		return false                                     #返回假 即不添加物品
	var 可放置区域 = _查找物品可用格子区域(物品)            #定义 可放置区域数组
	if 可放置区域.is_empty():                        #如果 可放置区域是空值,即无可放置区域
		return false                                     #返回假 即不添加物品
												   # === 所有验证通过后执行正式逻辑 ===
	_放置物品到格子(物品, 可放置区域)                   # _放置物品到格子(物品, 可放置区域)
	return true                                          #返回真 即添加物品
	
func 移除物品(物品: 物品类, 保持悬停状态: bool = false) -> void:
	$AudioStreamPlayer.play()
	if not _物品映射表.has(物品):
		return
		
	var 主格子 = _物品映射表[物品]
	var 占用格子 = _获取原始物品占用格子列表(主格子, 物品)
	物品.记录原始位置(主格子, 占用格子) # 把记录传给物品里的记录函数
	
	_物品映射表.erase(物品)
	if is_instance_valid(物品) and 物品.get_parent() == _物品容器: 
		_物品容器.remove_child(物品)
		
	for 格子 in 物品.获取原始占用格子列表():
		if is_instance_valid(格子):
			格子.清空格子()
			格子.更新基础状态()
				
## 快速移动
func 快速移动物品(物品: 物品类) -> void:
	if not is_instance_valid(物品):
		return
	for 目标仓库 in _快速转移目标列表:
		if not is_instance_valid(目标仓库):
			continue
		if 目标仓库.添加物品(物品):
			移除物品(物品)
			return

## 装备操作穿戴
func 装备物品(物品: 物品类) -> void:
	全局设置.穿戴装备(物品, self)

## 目标管理
func 添加快速移动目标(目标: 仓库容器类) -> void: 
	_快速转移目标列表.append(目标)
func 移除快速移动目标(目标: 仓库容器类) -> void: 
	_快速转移目标列表.erase(目标)
	
##=======================
##  公开接口的辅助函数
##=======================
func _查找物品可用格子区域(物品: 物品类) -> Array[格子类]:
	for 格子 in _全部格子:
		if not 格子.格子空闲中():
			continue
		var 覆盖格子列表 = _获取携带物品占用格子列表(格子, 物品) #物品的全部格子存在 才会返回数组 否则返回空0
		# 检查物品是否能完整放置在此格子及其关联区域
		if not 覆盖格子列表.is_empty(): # 更直观的空列表检查 即 覆盖格子列表为空是假->覆盖格子列表返回了数组
			return 覆盖格子列表    # 返回首个可用区域
	return []
	
func _放置物品到格子(物品: 物品类, 可放置区域: Array[格子类]) -> void:
	$AudioStreamPlayer.play()
	# 1. 确保物品在正确的父节点下
	if not 物品.get_parent():
		_物品容器.add_child(物品)
	else:
		物品.reparent(_物品容器)
	# 2. 更新物品映射表（记录物品与主格子的关系）
	_物品映射表[物品] = 可放置区域[0]
	# 3. 计算物品尺寸并遍历占用格子
	var 物品尺寸 := 物品.获取物品尺寸().x
	for i in range(可放置区域.size()):
		var 偏移 := Vector2i(
							i % 物品尺寸,  # X轴偏移
							i / 物品尺寸   # Y轴偏移（整数除法）
							)
		可放置区域[i].占用格子(物品, 偏移, 可放置区域) # 标记格子为占用状态
	# 4. 设置物品位置（对齐到主格子）
	物品.global_position = 可放置区域[0].global_position
	
	
# 添加原始占用格子列表计算函数（保持原来的算法）
func _获取原始物品占用格子列表(物品主格子: 格子类, 物品: 物品类, 偏移: Vector2i = Vector2i.ZERO, 
						 忽略占用: bool = false) -> Array[格子类]:
	var 物品尺寸 = 物品.获取物品尺寸()
	if 物品尺寸.x <= 0 or 物品尺寸.y <= 0:
		return []
		
	var 起始索引 = 物品主格子._索引 - (偏移.x + 偏移.y * 仓库列数)
	if 起始索引 < 0 or 起始索引 >= _全部格子.size():
		return []
		
	var 起始列 = 起始索引 % 仓库列数
	var 起始行 = 起始索引 / 仓库列数
	if 起始列 < 0 or 起始行 < 0:
		return []
	if 起始列 + 物品尺寸.x > 仓库列数 or 起始行 + 物品尺寸.y > 仓库行数:
		return []
		
	var 物品占用格子列表: Array[格子类] = []
	var 行起始索引 = 起始行 * 仓库列数
	for y in range(物品尺寸.y):
		var y行索引 = 行起始索引 + y * 仓库列数
		for x in range(物品尺寸.x):
			var 当前格子索引 = y行索引 + (起始列 + x)
			
			if 当前格子索引 >= _全部格子.size():
				return []
				
			if not 忽略占用:
				if not _全部格子[当前格子索引].格子空闲中() and _全部格子[当前格子索引].获取物品() != 物品:
					return []
			物品占用格子列表.append(_全部格子[当前格子索引])
	
	return 物品占用格子列表
func _获取携带物品占用格子列表(鼠标所在的格子: 格子类, 物品: 物品类, 偏移: Vector2i = Vector2i.ZERO, 
				   忽略占用: bool = false) -> Array[格子类]:
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
