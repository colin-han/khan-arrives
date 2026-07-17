# khan-arrives 项目说明

本仓库用于制作「Khan驾到」公众号 / 微信朋友圈的配图与文案。

## 主要工作流：朋友圈图片 + 文案

用户会给出：话题内容、目标受众、初稿文案。流程：

1. **澄清需求**（用 AskUserQuestion）：图片比例、视觉风格、核心概念的呈现方式、是否署名。
2. **生成产物**，放在 `{YYYY-MM-DD}-{slug}/` 目录下：
   - `image.html` — 用于截图的单文件 HTML
   - `text.txt` — 优化后的朋友圈文案
3. **预览与自查**：`open image.html` 给用户预览；同时用 Chrome headless 截图自查排版：
   ```
   "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --disable-gpu \
     --screenshot={scratchpad}/preview.png --window-size=1160,1530 --hide-scrollbars "file://{路径}/image.html"
   ```
   （比 Playwright 快且无需安装，机器上已装 Chrome。）
4. **导出成品**：用户预览确认后说「生成截图」等指令时，用 `export-image` skill（`.claude/skills/export-image/`）把 `image.html` 导出为同目录下的 `image.png`（默认 2160×2880）。

## 图片设计规范（2026-07-17 确立，用户已确认偏好）

- **比例**：3:4 竖版，画布固定 `1080px × 1440px`（朋友圈单图显示效果好）。
- **风格**：浅色极简 / 编辑风。暖白底（`#faf7f2`），墨色文字，单一强调色（如朱红 `#d4441c`），细线内边框营造版心。
- **字体**：标题用宋体（`"Songti SC", "Noto Serif SC", serif`），正文用 `"PingFang SC"`。全部系统字体，不依赖网络。
- **信息密度**：图片承载视觉比喻/结构，解释性文字交给朋友圈文案；字要大（正文 ≥ 26px @1080 宽），受众用手机看。
- **对比性内容**：次要对比放角落灰调小卡片（`#f0ece4` 底），不与主体抢空间。
- **署名**：左下角「Khan驾到」（宋体 + 强调色短横线），右下角可放英文主题词。
- **标点**：中文语境用「」引号，不用 ""。注意避免标题/副标题出现孤行。

## 文案规范

- 目标 50 字以内，但**内容完整优先于长度**；在不牺牲信息的前提下压缩。
- 口语化、比喻先行，适合没有 vibe coding 经验但了解 AI 辅助编程的朋友。
