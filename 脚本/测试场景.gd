extends Control


@onready var 仓库: 仓库容器类 = $"仓库/仓库"
@onready var 背包: 仓库容器类 = $"背包/背包"





@onready var 头盔装备槽: 装备槽类 = $背包/装备槽/头盔装备槽
@onready var 盔甲装备槽: 装备槽类 = $背包/装备槽/盔甲装备槽
@onready var 腰带装备槽: 装备槽类 = $背包/装备槽/腰带装备槽
@onready var 靴子装备槽: 装备槽类 = $背包/装备槽/靴子装备槽
@onready var 武器装备槽: 装备槽类 = $背包/装备槽/武器装备槽
@onready var 盾牌装备槽: 装备槽类 = $背包/装备槽/盾牌装备槽
@onready var 护腕装备槽: 装备槽类 = $背包/装备槽/护腕装备槽
@onready var 项链装备槽: 装备槽类 = $背包/装备槽/项链装备槽
@onready var 戒指装备槽: 装备槽类 = $背包/装备槽/戒指装备槽
@onready var 戒指装备槽2: 装备槽类 = $背包/装备槽/戒指装备槽2


var is_open = false



@onready var 物品提示框: 物品提示框类 = preload("res://场景/物品提示框.tscn").instantiate()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Button.pressed.connect(_on_button_pressed)
	$TextureButton.pressed.connect(_on_texture_button_pressed)
	close()
	add_child(物品提示框)
	物品提示框.hide()  # 初始隐藏

func _on_texture_button_pressed() -> void:
	visible = false
	is_open = false
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("c"):
		if is_open:
			close()
		else:
			open()
func open():
	visible = true
	is_open = true

func close():
	visible = false
	is_open = false

	
func _on_button_pressed() -> void:
	#$AudioStreamPlayer.play()
	# 所有物品资源的路径数组
	var 物品资源路径数组 = [
							"res://物品资源/盔甲资源/盔甲.tres",
							"res://物品资源/盔甲资源/盔甲2.tres",
							"res://物品资源/头盔资源/头盔.tres",
							"res://物品资源/头盔资源/头盔2.tres",
							"res://物品资源/盾牌资源/盾牌.tres",
							"res://物品资源/盾牌资源/盾牌2.tres",
							"res://物品资源/腰带资源/腰带.tres",
							"res://物品资源/腰带资源/腰带2.tres",
							"res://物品资源/靴子资源/靴子.tres",
							"res://物品资源/靴子资源/靴子2.tres",
							"res://物品资源/护腕资源/护腕.tres",
							"res://物品资源/护腕资源/护腕2.tres",
							"res://物品资源/项链资源/项链.tres",
							"res://物品资源/项链资源/项链2.tres",
							"res://物品资源/戒指资源/戒指.tres",
							"res://物品资源/戒指资源/戒指2.tres",
							"res://物品资源/武器资源/剑资源/剑.tres",
							"res://物品资源/武器资源/剑资源/剑2.tres",
							"res://物品资源/武器资源/锤资源/锤.tres",
							"res://物品资源/武器资源/锤资源/锤2.tres",
							"res://物品资源/武器资源/弓资源/弓.tres",
							"res://物品资源/武器资源/弓资源/弓2.tres",
							"res://物品资源/矿石资源/矿石.tres",
							"res://物品资源/矿石资源/矿石2.tres",
							"res://物品资源/盔甲资源/盔甲3.tres"
							
							
							
							
							
							
						]
	# 遍历所有路径，加载并添加到仓库
	for 路径 in 物品资源路径数组:
		var 物品 = 物品类.创建物品(load(路径))
		仓库.添加物品(物品)
	
	
	仓库.添加快速移动目标(背包)
	背包.添加快速移动目标(仓库)
	
	# 点击仓库的物品,尝试向目标装备槽移动
	全局设置.添加右键目标装备槽(头盔装备槽)
	全局设置.添加右键目标装备槽(盔甲装备槽)
	全局设置.添加右键目标装备槽(盾牌装备槽)
	全局设置.添加右键目标装备槽(腰带装备槽)
	全局设置.添加右键目标装备槽(靴子装备槽)
	全局设置.添加右键目标装备槽(护腕装备槽)
	全局设置.添加右键目标装备槽(项链装备槽)
	全局设置.添加右键目标装备槽(戒指装备槽)
	全局设置.添加右键目标装备槽(戒指装备槽2)
	全局设置.添加右键目标装备槽(武器装备槽)
	
	# 点击装备槽的物品,尝试向目标仓库移动
	全局设置.添加右键目标仓库(背包)
	
