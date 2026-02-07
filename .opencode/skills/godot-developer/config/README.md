# 项目动态配置

## 配置说明

`project-config.json` 文件用于存储项目特定的目录路径和设置，使 godot-developer 技能能够适应不同的项目结构。

## 配置项说明

### 路径配置 (paths)

- **backlog**: 项目backlog文档路径
- **gdd**: 游戏设计文档(GDD)路径
- **architecture**: 游戏架构概要设计文档路径
- **story_folder**: Story文档所在文件夹路径
- **output_folder**: 手把手开发指导输出文件夹路径
- **test_folder**: 测试文件存放路径

### 设置配置 (settings)

- **auto_create_folders**: 是否自动创建不存在的文件夹
- **confirm_before_execution**: 执行前是否需要用户确认
- **backup_existing_files**: 是否备份已存在的文件

## 使用方法

1. 首次使用技能时，系统会询问并自动配置这些路径
2. 后续使用时会自动加载配置，也支持重新配置
3. 配置文件会保存在技能的config目录中