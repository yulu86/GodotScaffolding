---
name: godot-web-verify
description: >
  Godot 4.x 项目导出 Web 版并用 playwright-cli 做黑盒自动验证（替代玩家手工验收）。
  覆盖端到端流程：web 导出 → 启动本地 https 服务（自签证书 + COOP/COEP 头）→
  playwright-cli 打开游戏并验证 AC（场景切换/配色/按钮交互/数值日志）→ 停止服务 →
  清理 build/ 与临时文件。
  当用户要求验证 Godot web 导出、自动验收 Godot story、黑盒测试 Godot 游戏、
  playwright 验证 Godot、web 端渲染验证、像素采样配色核验、AC1/AC2 自动验证时使用此技能。
  触发词：web 验证、自动验收、playwright 验证、Godot web 导出、黑盒验证 Godot、
  像素采样配色、AC 验证、scene switch 验证、停止 https、清理 build。
---

# Godot Web Verify

通过「web 导出 + playwright-cli 自动化」对 Godot 游戏做**黑盒验证**，替代玩家手工验收（宪法 C2）。核心价值：AI 无法"看见"渲染结果，但可通过 **console 日志 + 像素采样 + 鼠标坐标点击** 客观验证渲染与交互，无需人眼。

## 适用边界

- ✅ **适用**：Godot 4.x 项目、Web 导出目标、需验证 UI 渲染/场景切换/配色/按钮交互/数值变化的 story
- ❌ **不适用**：纯逻辑模块（无 UI）、桌面端原生导出、需要手柄/触觉反馈的场景（Web 无法体现）

## 前置条件

1. **godot 可执行**：从 `$GODOT_HOME`（Windows 用 PowerShell `$env:GODOT_HOME`）或 PATH 读取（遵从全局 §1.4）
2. **导出预设**：项目已有 Web 导出预设（`export_presets.cfg` 含 `platform="Web"`），输出路径默认 `build/index.html`
3. **Python 3.x**：用于起 https 服务
4. **playwright-cli**：已全局安装（`npm i -g @playwright/cli`）；本地 Chrome 已安装（遵从全局 §2.7，禁止用 Playwright 自带 Chromium）
5. **PIL（Pillow）**：用于像素采样验证配色

> 若 `playwright-cli` 不可用，本 skill 降级为「仅导出 + 人工浏览器验收」，并在回复中注明。

## 工作流总览

```
①导出 web  →  ②起 https 服务(8443)  →  ③playwright 打开+验证
                                              ↓
        ⑤清理(build/ + .tmp/ + 服务进程)  ←  ④停止服务
```

> **强制**：流程结束后**必须**执行 ④⑤ 清理（宪法 §1.7 临时文件管理 + D1 build/ 不提交）。

---

## 步骤 ① · Web 导出

按宪法 E1 命令导出（项目根目录执行）：

```bash
$GODOT_HOME --headless --export-release "Web" build/index.html
```

- 导出前若新增/改动了 `.gd`/图片/音频/`.tscn`，**必须先**跑 `$GODOT_HOME --headless --import` 生成 `.uid`/`.import`（宪法 D1）
- 导出预设名通常是 `"Web"`，若不确定先查 `export_presets.cfg` 的 `name=`
- 输出固定到 `build/index.html`（Godot web 导出会生成 `index.html` + `index.js` + `index.pck` + `index.wasm` 等）

**验证导出成功**：`build/index.html` 存在且 `index.wasm` 大小 > 10MB（wasm 引擎本体）。

---

## 步骤 ② · 启动本地 https 服务（端口 8443）

> **为什么必须 https**：Godot 4 web 默认用多线程，需要 `SharedArrayBuffer`，而浏览器**只在安全上下文（https 或 localhost）**才启用。localhost 虽算安全上下文，但配合 COOP/COEP 头更稳妥，故统一用 https + 自签证书。

### 2.1 生成自签证书（一次性，存 `.tmp/`）

```bash
mkdir -p .tmp
MSYS_NO_PATHCONV=1 openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout .tmp/key.pem -out .tmp/cert.pem -days 365 -subj "/CN=localhost"
```

> **Windows + Git Bash 坑**：`-subj "/CN=localhost"` 会被 MSYS 路径转换成 `C:/Program Files/Git/CN=localhost` 导致失败。**必须**加 `MSYS_NO_PATHCONV=1` 前缀。

### 2.2 启动 https 服务（后台）

本 skill 内置服务器脚本（见 `scripts/https_server.py`），固定监听 `8443`，已注入 Godot web 必需的三个 Cross-Origin 头：

```bash
python .zcode/skills/godot-web-verify/scripts/https_server.py
```

用 `run_in_background: true` 后台运行，会打印 `[https] serving <build_dir> on https://localhost:8443`。

> **若 skill 目录不可访问**（如 skill 被复制到其他路径），降级方案：复制 `scripts/https_server.py` 到项目 `.tmp/https_server.py` 再运行。脚本内 `BUILD_DIR` 默认指向 `<skill上级两级>/build`，即项目根的 `build/`。

### 2.3 验证服务可访问

> **重要**：https 服务**不能用 curl 验证**（Windows curl 的 schannel 后端与 Python ssl 重协商不兼容，返回 HTTP 000 误报）。验证服务请直接用 playwright 打开（步骤 ③），或用 `openssl s_client` 测 TLS 握手。

**正确验证方式 1**（推荐，直接进步骤 ③）：用 playwright 打开，看是否加载成功。

**正确验证方式 2**（仅测 TLS 握手是否就绪）：
```bash
echo | openssl s_client -connect localhost:8443 -servername localhost 2>/dev/null | grep -i "CONNECTED\|verify"
# 期望：CONNECTED 字样（自签证书 verify 会失败，正常）
```

---

## 步骤 ③ · playwright-cli 自动验证

### 3.1 写 playwright config（忽略自签证书）

在项目 `.playwright/cli.config.json` 写入（本 skill 内置模板见 `assets/cli.config.json`）：

```json
{
  "browser": {
    "browserName": "chromium",
    "launchOptions": {
      "channel": "chrome",
      "headless": false,
      "args": ["--ignore-certificate-errors"]
    },
    "contextOptions": {
      "ignoreHTTPSErrors": true
    }
  }
}
```

> **关键坑**：`args` 里**禁止**同时加 `--disable-web-security`！它会移除浏览器的 COOP/COEP 判定，导致 Godot 报 `Cross-Origin Isolation - missing` 错误，SharedArrayBuffer 失效。只保留 `--ignore-certificate-errors` 即可。

### 3.2 打开游戏

```bash
playwright-cli open https://localhost:8443/index.html --config=.playwright/cli.config.json
sleep 5  # 等 Godot wasm 加载（wasm 越大等越久，index.wasm ~38MB 时约 5s）
```

### 3.3 验证手段（按 AC 需求选用）

#### A. 日志验证（场景加载/状态切换/信号触发）

Godot 的 `print()` 会输出到浏览器 console：

```bash
playwright-cli console
# 筛选关键日志
playwright-cli console | grep -i "READY\|NAV\|error"
```

**典型验证模式**：对照 story 的 AC，断言 console 出现预期日志链。例如场景切换验证：

```
[S01] MAIN_MENU_READY          ← 主菜单加载
[S01] NAV_BATTLE_TABLE         ← 点击「新的旅程」触发切换
[S01] BATTLE_TABLE_READY       ← 牌桌加载完成
```

#### B. 像素采样验证配色（客观，优先于图像分析 AI）

**禁止**仅靠图像分析 AI 的主观描述（像素字体 OCR 会误判，如把 `v0.1.0` 读成 `v8.1.0`、把「新的旅程」读成「开始游戏」）。**配色验证必须用 PIL 像素采样**：

```bash
playwright-cli screenshot --filename=.tmp/<场景>-验证.png
```

```python
from PIL import Image
img = Image.open('.tmp/<场景>-验证.png')
w, h = img.size
# 多点采样，对照原型规格 Hex
samples = {
    'center':  img.getpixel((w//2, h//2))[:3],
    'top_left': img.getpixel((w//4, h//4))[:3],
}
for name, rgb in samples.items():
    print(f'{name}: #{rgb[0]:02x}{rgb[1]:02x}{rgb[2]:02x}')
# 对照：牌桌绿 #1a5236 / 烟灰底 #15101e / 霓虹粉 #ff2e88
```

> **重要**：WebGL 的 `gl.readPixels` 在 `preserveDrawingBuffer=false`（Godot 默认）时会读到清空后的缓冲，**不可靠**。务必用截图 + PIL 读像素。

#### C. 鼠标坐标点击（canvas 内按钮交互）

Godot web 是纯 canvas，无 DOM 元素可 ref。`playwright-cli click` 需要 element ref，**对 canvas 无效**。改用坐标点击：

```bash
# mousemove + mousedown + mouseup 模拟点击
playwright-cli mousemove <x> <y>
playwright-cli mousedown left
playwright-cli mouseup left
```

**坐标计算**：视口坐标 = 逻辑坐标 × 缩放比。但 `aspect "expand"` 模式会裁剪，难以精确。**实用策略：扫描点击**（从上到下试不同 y 值，命中即停）：

```bash
for y in 280 320 360 400 440 480 520; do
  playwright-cli mousemove 466 $y >/dev/null 2>&1
  playwright-cli mousedown left >/dev/null 2>&1
  playwright-cli mouseup left >/dev/null 2>&1
  sleep 0.5
  if [ "$(playwright-cli console 2>&1 | grep -c 'NAV_BATTLE')" -gt 0 ]; then
    echo "HIT at y=$y"; break
  fi
done
```

> **备选**：用 `playwright-cli eval` 派发完整 PointerEvent 序列（含 pointerdown/up），但坐标命中问题一样存在，扫描点击更省事。
> **键盘无效**：`press Tab/Enter` 在 canvas 内不生效（焦点不在 DOM）。

#### D. 截图留证

每个关键操作后截图，存 `.tmp/<story-id>-<步骤>.png`，作为验证证据（阻塞排查用，story 通过后随 `.tmp/` 一起删）。

### 3.4 AC 验证对照表示例

按 story 的 AC 逐条核验，输出对照表：

| AC | 验证手段 | 证据 | 结果 |
|----|---------|------|:---:|
| AC1 主菜单加载 | console 日志 | `[S01] MAIN_MENU_READY` | ✅ |
| AC2 进入牌桌 | console + 像素采样 | `NAV_BATTLE_TABLE` + 牌桌绿 `#1a5236` | ✅ |
| AC3 返回主菜单 | console 日志 | `NAV_MAIN_MENU` → `MAIN_MENU_READY` | ✅ |
| AC4 配色基线 | PIL 像素采样 | 烟灰底/牌桌绿/霓虹粉 Hex 对齐 | ✅ |

---

## 步骤 ④ · 停止 https 服务

验证结束后**立即停止**后台 https 进程。若用 `run_in_background` 启动，记录返回的 task_id，用对应工具停止：

```bash
# 若是本 skill 工具启动的后台任务：用 TaskStop <task_id>
# 若需手动清理残留 python 进程（端口 8443）：
# Windows: netstat -ano | grep 8443  找到 PID 后 taskkill /PID <pid> /F
```

---

## 步骤 ⑤ · 清理（强制）

流程结束后**必须**清理（宪法 §1.7 + D1）：

1. **关闭浏览器**：`playwright-cli close`（残留用 `playwright-cli kill-all`）
2. **停止 https 服务**：见步骤 ④
3. **删除导出产物**：`rm -rf build/`（gitignore 已屏蔽，但磁盘要清）
   - 若提示 `Device or resource busy`（chrome 缓存了 wasm 句柄），先 `playwright-cli kill-all` 等几秒再删；目录删空即可，空目录不影响提交
4. **删除 `.playwright/` 和 `.playwright-cli/`**：playwright 运行时生成的 config + snapshot，gitignore 应屏蔽（若未屏蔽，追加到 `.gitignore`）
5. **删除 `.tmp/` 验证截图**：story 通过后，截图证据随 `.tmp/` 一起删（仅阻塞排查期间保留）
6. **保留**：`.tmp/` 下的证书（`cert.pem`/`key.pem`）和 `https_server.py` 若下次还要用，可保留；但任务真正结束时应一并删

> **`.gitignore` 必备项**（若项目未配置，提示用户补充）：
> ```
> build/
> .tmp/
> .playwright/
> .playwright-cli/
> ```

---

## 常见问题排查

### Q1: 打开后 console 报 `Cross-Origin Isolation - missing` / `SharedArrayBuffer` 缺失
**A**: https 服务的 COOP/COEP/CORP 三个头没发对。检查 `scripts/https_server.py` 的 `end_headers` 是否注入了：
```
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
Cross-Origin-Resource-Policy: same-origin
```
同时确认 playwright config 的 `args` **没有** `--disable-web-security`。

### Q1.5: chrome 报 `ERR_INVALID_HTTP_RESPONSE`（TLS 握手后 HTTP 响应无效）
**A**: https 服务的 Handler 注册方式有问题。**禁止**用 `lambda`/闭包传给 `ThreadingHTTPServer`：
```python
# 错误写法 —— 会触发 chrome ERR_INVALID_HTTP_RESPONSE（TLS 重协商/HTTP 分帧异常）
server = ThreadingHTTPServer(addr, lambda *a, **kw: Handler(*a, directory=build_dir, **kw))

# 正确写法 —— 直接传 Handler 类，directory 通过类属性注入
Handler.serve_dir = build_dir
server = ThreadingHTTPServer(addr, Handler)
```
本 skill 的 `scripts/https_server.py` 已用正确写法（类属性 + 直接传类），勿擅自改回 lambda。

### Q1.6: `curl https://localhost:8443` 返回 `HTTP 000`，但 playwright 能正常打开
**A**: 这是 **curl 的 schannel 后端** 与 Python ssl 的 TLS 重协商不兼容，**不是服务问题**。playwright/chrome 用 OpenSSL 后端不受影响。验证服务请用 playwright，**不要用 curl 判断 https 服务可用性**（http 服务可以用 curl，https 不行）。

### Q2: 页面打开但 Godot 没加载（console 无 `Godot Engine` 日志）
**A**: wasm 还在加载。多等几秒（`sleep 8`）。或检查 `build/index.wasm` 是否生成、`index.pck` 是否非空。

### Q3: 点击按钮没反应
**A**: canvas 坐标没命中。见步骤 ③.C 的扫描点击策略。按钮在 canvas 内无 DOM，只能靠坐标试。

### Q4: 像素采样颜色和预期差很多
**A**: ① 确认当前在正确场景（看 console 日志）；② 多点采样（不只看中心）；③ 若整屏是 `#4d4d4d` 中性灰，可能是**场景根 Control 没设 Full Rect anchor**（参见 MEMORY `#场景` 经验），渲染的是引擎默认清屏色。

### Q5: `rm -rf build/` 报 `Device or resource busy`
**A**: chrome 缓存了 wasm 句柄。先 `playwright-cli kill-all`，等 3-5 秒再删。目录内容删空即可，空目录不阻塞提交（build/ 在 gitignore）。

---

## 与宪法的关系

- **替代 C2 玩家手工验证**：本 skill 是 AI 自主开发模式（`/godot-dev-stories` 命令）步骤 2 的具体实现，用 playwright-cli 自动化替代玩家试玩黑盒验收
- **不替代 B5 自动化测试**：本 skill 验证「渲染/交互跑起来对不对」，GdUnit4 单元测试验证「逻辑对不对」——两者互补，**都不可省略**（单元测试通过 ≠ 渲染正确，详见 MEMORY `#测试` 经验）
- **不替代 C7 原型差异分析**：C7 是静态对照原型规格文档，本 skill 是运行期黑盒验收
