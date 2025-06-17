# 物品提示框脚本（完整优化版）

extends Panel
class_name 物品提示框类


@onready var 名称标签: Label = $VBoxContainer/名称标签
@onready var 类型标签: Label = $VBoxContainer/类型标签


@onready var 属性标签: RichTextLabel = $VBoxContainer/属性标签

@onready var 描述标签: Label = $VBoxContainer/描述标签



func _ready() -> void:
	#size = Vector2(250, 0)
	#custom_minimum_size = Vector2(250, 0)
	hide()

func 显示物品信息(物品数据: 物品资源类, 位置: Vector2) -> void:
	名称标签.text = 物品数据.物品名称
	名称标签.add_theme_color_override("font_color", 物品数据.获取颜色())
	
	类型标签.text = 物品数据.获取类型名称()   # "类型: " + 
	
	属性标签.clear()
	#属性标签.push_color(物品数据.获取颜色())
	属性标签.append_text("[color=#FFD700]┍ 物品属性 ┑[/color]\n")
	#属性标签.pop()
	# 添加具体属性（自动过滤0值属性）
	属性标签.append_text(物品数据.获取属性文本())
	
	
	
	
	
	
	
	
	
	
	描述标签.text = 物品数据.物品描述
	

	
	# 调整布局
	await _调整布局(位置)

#func _调整布局(位置: Vector2) -> void:
	#await get_tree().process_frame  # 等待渲染完成
	#
	## 自动计算大小
	#size = Vector2.ZERO
	##custom_minimum_size = Vector2(200, 100)  # 设置最小宽度
	#
	## 定位（避开鼠标）
	#global_position = 位置 + Vector2(25, -10)
	#
	## 确保不超出屏幕
	#var 视口 = get_viewport().get_visible_rect()
	#if global_position.x + size.x > 视口.end.x:
		#global_position.x = 视口.end.x - size.x + 50
	#if global_position.y + size.y > 视口.end.y:
		#global_position.y = 视口.end.y - size.y - 150
	#
	#show()
	
func _调整布局(位置: Vector2) -> void:
	# 确保样式加载
	var 背景样式 = StyleBoxFlat.new()
	背景样式.bg_color = Color(0.1, 0.1, 0.1, 0.3)  # 深色半透明
	背景样式.corner_radius_top_left = 5
	背景样式.corner_radius_top_right = 5
	背景样式.corner_radius_bottom_right = 5
	背景样式.corner_radius_bottom_left = 5
	背景样式.set_content_margin_all(10)
	add_theme_stylebox_override("panel", 背景样式)
	
	# 紧凑布局
	custom_minimum_size = Vector2(122, 220)  # 更小宽度
	size = Vector2.ZERO
	
	# 等待布局计算
	await get_tree().process_frame
	
	
	# 获取实际尺寸（确保至少120高度）
	var 菜单尺寸 = Vector2(max(size.x, 150), max(size.y, 150))
	
	# 紧凑偏移（距离物品更近）
	var 初始偏移 = Vector2(15, 10)  # 比原来更靠近
	var 新位置 = 位置 + 初始偏移
	
	# 屏幕边界检测
	var 视口 = get_viewport().get_visible_rect()
	
	# 右侧检测
	if 新位置.x + 菜单尺寸.x > 视口.end.x:
		新位置.x = 位置.x - 菜单尺寸.x + 5  # 向左显示
	
	# 下侧检测
	if 新位置.y + 菜单尺寸.y > 视口.end.y:
		新位置.y = 位置.y - 菜单尺寸.y - 5  # 向上显示
	
	# 最终位置保护
	新位置 = Vector2(
		clamp(新位置.x, 5, 视口.end.x - 菜单尺寸.x - 5),
		clamp(新位置.y, 5, 视口.end.y - 菜单尺寸.y - 5)
	)
	
	global_position = 新位置
	show()



func 隐藏提示() -> void:
	hide()
