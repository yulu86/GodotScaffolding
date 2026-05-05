# Godot MCP工具使用指南

## 可用的Godot MCP工具

### 项目管理
- `mcp__godot__list_projects` - 列出目录中的Godot项目
- `mcp__godot__get_project_info` - 获取项目元数据
- `mcp__godot__get_godot_version` - 获取Godot版本

### 场景操作
- `mcp__godot__create_scene` - 创建新场景文件
- `mcp__godot__add_node` - 向场景添加节点
- `mcp__godot__save_scene` - 保存场景文件
- `mcp__godot__load_sprite` - 加载精灵到Sprite2D节点
- `mcp__godot__export_mesh_library` - 导出场景为MeshLibrary资源

### 运行和调试
- `mcp__godot__launch_editor` - 启动Godot编辑器
- `mcp__godot__run_project` - 运行项目并捕获输出
- `mcp__godot__get_debug_output` - 获取当前调试输出和错误
- `mcp__godot__stop_project` - 停止正在运行的项目

### UID管理（Godot 4.4+）
- `mcp__godot__get_uid` - 获取文件的UID
- `mcp__godot__update_project_uids` - 更新项目中的UID引用

## 使用示例

### 创建基本场景结构
```python
# 创建主场景
mcp__godot__create_scene(
    projectPath="/path/to/project",
    scenePath="scenes/main/main.tscn",
    rootNodeType="Node"
)

# 添加玩家节点
mcp__godot__add_node(
    projectPath="/path/to/project",
    scenePath="scenes/main/main.tscn",
    parentNodePath="root",
    nodeType="CharacterBody2D",
    nodeName="Player"
)
```

### 运行和测试
```python
# 启动编辑器
mcp__godot__launch_editor(projectPath="/path/to/project")

# 运行项目
mcp__godot__run_project(projectPath="/path/to/project")

# 获取调试输出
output = mcp__godot__get_debug_output()
```