# Godot MCP工具使用指南

## 概述

Godot MCP (Model Context Protocol) 工具是一套专门用于与Godot游戏引擎交互的工具集，允许通过MCP协议直接操作Godot项目、创建资源、运行项目等。

## 核心工具列表

### 项目管理工具

#### `get_godot_version`
获取当前安装的Godot版本信息。

```python
# 使用示例
version_info = get_godot_version()
```

#### `list_projects`
列出指定目录下的所有Godot项目。

```python
# 使用示例
projects = list_projects(directory="path/to/projects", recursive=True)
```

#### `get_project_info`
获取指定Godot项目的详细元数据信息。

```python
# 使用示例
project_info = get_project_info(projectPath="path/to/godot/project")
```

### 编辑器控制工具

#### `launch_editor`
启动Godot编辑器并打开指定项目。

```python
# 使用示例
launch_editor(projectPath="path/to/godot/project")
```

### 项目运行工具

#### `run_project`
运行Godot项目并捕获输出信息。

```python
# 使用示例
run_project(projectPath="path/to/godot/project", scene="res://Main.tscn")
```

#### `stop_project`
停止当前正在运行的Godot项目。

```python
# 使用示例
stop_project()
```

#### `get_debug_output`
获取当前项目的调试输出和错误信息。

```python
# 使用示例
debug_info = get_debug_output()
```

### 场景操作工具

#### `create_scene`
创建新的Godot场景文件。

```python
# 使用示例
create_scene(
    projectPath="path/to/godot/project",
    scenePath="scenes/NewScene.tscn",
    rootNodeType="Node2D"
)
```

#### `save_scene`
保存场景文件的更改。

```python
# 使用示例
save_scene(
    projectPath="path/to/godot/project",
    scenePath="scenes/Player.tscn",
    newPath="scenes/Player_v2.tscn"  # 可选，用于创建变体
)
```

#### `add_node`
向现有场景添加新节点。

```python
# 使用示例
add_node(
    projectPath="path/to/godot/project",
    scenePath="scenes/Player.tscn",
    parentNodePath="root",
    nodeType="Sprite2D",
    nodeName="PlayerSprite",
    properties={"texture": "res://player.png"}
)
```

### 资源管理工具

#### `load_sprite`
将纹理文件加载到Sprite2D节点中。

```python
# 使用示例
load_sprite(
    projectPath="path/to/godot/project",
    scenePath="scenes/Player.tscn",
    nodePath="root/PlayerSprite",
    texturePath="assets/player.png"
)
```

#### `export_mesh_library`
将场景导出为MeshLibrary资源。

```python
# 使用示例
export_mesh_library(
    projectPath="path/to/godot/project",
    scenePath="scenes/Environment.tscn",
    outputPath="resources/environment_meshlib.res",
    meshItemNames=["Tree", "Rock", "Building"]  # 可选，默认导出所有
)
```

### UID管理工具 (Godot 4.4+)

#### `get_uid`
获取项目中指定文件的唯一标识符(UID)。

```python
# 使用示例
file_uid = get_uid(
    projectPath="path/to/godot/project",
    filePath="scenes/Player.tscn"
)
```

#### `update_project_uids`
更新项目中的UID引用（重新保存所有资源）。

```python
# 使用示例
update_project_uids(projectPath="path/to/godot/project")
```

## 使用最佳实践

### 1. 项目初始化流程
```python
# 1. 检查Godot版本
version = get_godot_version()

# 2. 获取项目信息
project_info = get_project_info(projectPath)

# 3. 启动编辑器（如需要）
launch_editor(projectPath=projectPath)
```

### 2. 场景创建流程
```python
# 1. 创建新场景
create_scene(
    projectPath=projectPath,
    scenePath="scenes/Player.tscn",
    rootNodeType="CharacterBody2D"
)

# 2. 添加子节点
add_node(
    projectPath=projectPath,
    scenePath="scenes/Player.tscn",
    nodeType="Sprite2D",
    nodeName="Sprite"
)

add_node(
    projectPath=projectPath,
    scenePath="scenes/Player.tscn",
    nodeType="CollisionShape2D",
    nodeName="Collision"
)

# 3. 保存场景
save_scene(projectPath=projectPath, scenePath="scenes/Player.tscn")
```

### 3. 开发测试循环
```python
# 1. 运行项目进行测试
run_project(projectPath=projectPath, scene="res://Main.tscn")

# 2. 获取调试输出
debug_info = get_debug_output()

# 3. 分析错误信息
if "ERROR" in debug_info:
    # 处理错误
    pass

# 4. 停止项目
stop_project()
```

### 4. 资源管理
```python
# 1. 加载精灵资源
load_sprite(
    projectPath=projectPath,
    scenePath="scenes/Player.tscn",
    nodePath="root/Sprite",
    texturePath="assets/player.png"
)

# 2. 导出网格库（用于TileMap等）
export_mesh_library(
    projectPath=projectPath,
    scenePath="scenes/Tiles.tscn",
    outputPath="resources/tile_meshlib.res"
)
```

## 错误处理

### 常见错误类型

1. **项目路径错误**
   - 确保项目路径存在且包含project.godot文件
   - 使用绝对路径避免相对路径问题

2. **场景文件不存在**
   - 在操作场景前确保场景文件已创建
   - 使用create_scene先创建场景

3. **节点路径错误**
   - 确保节点路径格式正确（如："root/PlayerSprite"）
   - 检查父节点是否存在

4. **资源文件路径错误**
   - 确保资源文件路径相对于项目根目录
   - 使用"res://"前缀表示项目资源路径

### 错误处理示例
```python
try:
    project_info = get_project_info(projectPath)
except Exception as e:
    print(f"获取项目信息失败: {e}")
    # 处理错误情况
```

## 性能优化建议

1. **批量操作**：尽量一次性完成多个相关操作
2. **及时保存**：重要修改后立即保存场景
3. **资源管理**：避免重复加载相同的资源
4. **调试输出**：频繁调用get_debug_output可能影响性能

## 注意事项

1. **路径格式**：统一使用正斜杠(/)作为路径分隔符
2. **项目状态**：确保项目在编辑器中关闭时进行文件操作
3. **版本兼容性**：UID相关功能需要Godot 4.4+
4. **内存管理**：大型项目操作时注意内存使用情况