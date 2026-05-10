extends CanvasLayer
class_name LoadingScreen

## 加载画面
## 场景切换时显示加载进度

const LOADING_TIPS: Array[String] = [
	"Coordinate with your team for better results!",
	"Destroy towers to open up the enemy base.",
	"Farm minions to earn gold and experience.",
	"Keep an eye on the minimap for enemy movements.",
	"Don't overextend without vision of enemies.",
	"Buy items that complement your hero's strengths.",
	"Objectives are more important than kills.",
	"Ward important areas to gain vision control.",
]

@onready var progress_bar: ProgressBar = $ColorRect/MarginContainer/VBoxContainer/ProgressBar
@onready var tip_label: Label = $ColorRect/MarginContainer/VBoxContainer/TipLabel
@onready var loading_label: Label = $ColorRect/MarginContainer/VBoxContainer/LoadingLabel
@onready var color_rect: ColorRect = $ColorRect

var progress: float = 0.0
var target_scene: String = ""
var loading_complete = false

func _ready():
	# 显示随机提示
	tip_label.text = "Tip: " + LOADING_TIPS[randi() % LOADING_TIPS.size()]
	loading_label.text = "Loading..."
	progress_bar.value = 0.0

func start_loading(scene_path: String):
	target_scene = scene_path
	loading_complete = false
	loading_label.text = "Loading..."

	# 开始异步加载
	ResourceLoader.load_threaded_request(scene_path)

func _process(_delta):
	if target_scene.is_empty() or loading_complete:
		return

	# 检查加载进度
	var load_progress: Array = []
	var status = ResourceLoader.load_threaded_get_status(target_scene, load_progress)

	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_bar.value = load_progress[0] * 100.0
		ResourceLoader.THREAD_LOAD_LOADED:
			progress_bar.value = 100.0
			loading_complete = true
			loading_label.text = "Ready!"
			_complete_load()
		ResourceLoader.THREAD_LOAD_FAILED:
			loading_label.text = "Load Failed!"
			push_error("[Loading] Failed to load: ", target_scene)

func _complete_load():
	# 短暂延迟后切换场景
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file(target_scene)
