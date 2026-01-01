# 代码开发
- 在开发Godot项目时，强制使用`godot-copilot`技能与我进行协同开发
- 必须使用`context7`工具获取gdscript语法和godot引擎API/SDK文档，禁止在编码时出现语法错误

# 项目目录规范
- assets目录：存放游戏资产
    - fonts：字体文件
	- music：游戏音乐文件(.wav,.ogg,.mp3等)
	- sounds：游戏音效文件(.wav,.ogg,.mp3等)
	- sprites：游戏图片
- scenes：Godot场景文件(.tscn文件，按游戏模块划分子目录)
- scripts：gdscript文件(.gd文件，按游戏模块划分子目录)
- test：单元测试
- addons：插件

# 实现原则
- 建议优先选择AnimationPlayer节点，而不是AnimatedSprite2D节点，以提供更多灵活性
- 需要在`项目设置`-`全局设置`中配置为singleton的.gd文件中禁止写`class_name`
- gdscript不支持三元运算符 ?: 语法，需要使用 if...else 替代
- 代码中除了注释外，禁止使用中文
- GUT测试代码中直接引用类，而不是使用load/preload加载类
- 测试代码使用子目录管理，相对路径与功能代码路径保持一致

# Godot引擎命令行
- GUT测试执行必须使用命令行
- windows环境下:
  godot命令对应的可执行文件 `E:\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe`，例如 ```godot -s addons/gut/gut_cmdln.gd -gexit``` -> ```E:\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe -s addons/gut/gut_cmdln.gd -gexit```
- macOS环境下:
  godot命令对应的可执行文件 `'/Users/xuyulu/Library/Application Support/Steam/steamapps/common/Godot Engine/Godot.app/Contents/MacOS/Godot'` ，例如 ```godot -s addons/gut/gut_cmdln.gd -gexit``` -> ```'/Users/xuyulu/Library/Application Support/Steam/steamapps/common/Godot Engine/Godot.app/Contents/MacOS/Godot' -s addons/gut/gut_cmdln.gd -gexit```
