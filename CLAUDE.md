# khan-arrives 项目说明

本仓库用于制作「Khan驾到」公众号 / 微信朋友圈的配图与文案。

## 受众

朋友圈读者——对 AI 辅助开发 / vibe coding 有一定了解，但**并非专业开发者**。能看懂大致概念，不需要深入技术细节；解释要从他们的认知出发，用比喻和具体场景，而不是术语堆砌。

## 内容原则（2026-07-18 确认，最高优先级）

- **细节优先，大概念只是脚手架**：内容要尽可能落在具体细节上。引入大概念（如「蒸馏老师傅」「Harness Learn」）的唯一目的是帮读者更快进入细节，而不是停留在概念层的金句式表达。**这是避免「AI 味」的根本**——AI 味的根源就是停在概念、缺细节。
- 由此推导出文案的三条操作要求：第一人称个人语气、反金句/营销腔、必须带真实个人细节（详见文案规范）。

## 记忆策略

这是个人仓库，**不使用 local memory**（`~/.claude/.../memory/`）。所有需要长期记住的偏好、约定、规范都写进本文件（CLAUDE.md）。唯一例外是 security 相关的敏感内容（token、密钥等），那些不入库。

## 主要工作流：朋友圈图片 + 文案

用户会给出：话题内容、初稿文案（受众已固定见上，**不再作为每次的输入**）。流程：

1. **澄清需求**（用 AskUserQuestion）：图片比例、视觉风格、核心概念的呈现方式、是否署名。
2. **生成产物**，放在 `{YYYY-MM-DD}-{slug}/` 目录下：
   - `image.html` — 用于截图的单文件 HTML
   - `text.txt` — 优化后的朋友圈文案
3. **预览与自查**：`open image.html` 给用户预览；同时截图自查排版。**务必做视觉校验**——不要只看文件生成，要用脚本/工具客观确认内容真的渲染了（如分段统计墨色像素密度判断文字是否在画布内、`document.fonts.check()` 判断字体是否真加载）。
   - **默认（纯系统字体）**：用 Chrome headless，快且无需安装：
     ```
     "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --disable-gpu \
       --screenshot={scratchpad}/preview.png --window-size=1080,1440 --hide-scrollbars \
       --force-device-scale-factor=1 "file://{路径}/image.html"
     ```
   - **用了网络字体时，必须改用 Playwright**：Chrome headless 直接 `--screenshot` 会**截在字体加载之前**（`font-display:swap` 先用系统字顶住），导致肉眼以为字体没生效。正确做法：起本地 `python3 -m http.server`（Playwright 禁 `file://`）→ Playwright `navigate` → `evaluate` 里 `await document.fonts.ready` 并强制触发标题/正文字形（`void el.offsetHeight`）→ 再 `screenshot`。
   - **模拟朋友圈整屏效果**：用仓库根的 `preview.html`（需在仓库根跑 `python3 -m http.server 8765`），访问 `http://localhost:8765/preview.html?topic={slug}`。它还原朋友圈排版（9:20 手机框、圆形头像、蓝绿昵称、文案、配图缩略、点赞评论、底部评论框），配图缩略宽度约为文字区一半，点击图片全屏。文案/图片通过 server fetch 对应 `{slug}/text.txt` 和 `{slug}/image.html`（iframe，无需导出 png）。
4. **导出成品**：用户预览确认后说「生成截图」等指令时，把 `image.html` 导出为同目录 `image.png`（2160×2880）。
   - **纯系统字体**：直接用 `export-image` skill 脚本（`.claude/skills/export-image/scripts/export_image.sh {slug}`）即可。
   - **用了网络字体时，别用 skill 脚本**——它有两个坑：① Chrome headless `--screenshot` 会**截在字体加载之前**（字体回退成系统字，肉眼以为没生效）；② 脚本注入的 `body{background:none}` 会**去掉 image.html 保留的暖白底**。改用直接命令（走本地 server URL 保留底色 + `--virtual-time-budget` 等字体）：
     ```
     "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --disable-gpu --hide-scrollbars \
       --window-size=1080,1440 --force-device-scale-factor=2 --virtual-time-budget=10000 \
       --screenshot={slug}/image.png "http://localhost:8765/{slug}/image.html"
     ```
   - **高分辨率导出必须用 `--force-device-scale-factor`，不要用 Playwright 的 `deviceScaleFactor`**：`browser.newContext({deviceScaleFactor:2})` + `page.screenshot()` 会把 1080×1440 内容只渲染在左上 **1/4**（deviceScaleFactor 不放大 CSS 内容）；只有 Chrome 的 `--force-device-scale-factor=2` 才会把内容真正放大填满 2160×2880。
   - **导出后必须客观校验**（本次踩坑总结）：① 看字体是否手写/书法体而非宋体黑体（或 `document.fonts.check`）；② 用脚本统计图片四象限墨色占比，确认内容填满整张——有象限为 0% 说明只截了局部或布局留白。

## 图片设计规范（2026-07-17 确立，用户已确认偏好）

- **比例**：3:4 竖版，画布固定 `1080px × 1440px`（朋友圈单图显示效果好）。
- **风格**：手绘插画质感（2026-07-18 调整，原「浅色极简 / 编辑风」）。强调「个人创作感」——线条有温度、可以不完美；**避免「找张照片配个标准标题」的素材拼接 / 模板感**。暖白底（`#faf7f2`）、墨色文字、单一强调色（朱红 `#d4441c`）保留。
- **字体**：默认走系统字体（标题 `"Songti SC", "Noto Serif SC", serif`，正文 `"PingFang SC"`），零加载、最稳。**允许使用网络字体**——当调性需要（如手绘插画质感）时从下方清单挑选，但**不要为换而换**：
  - 中文手写/书法：霞鹜文楷 `LXGW WenKai`（手绘方向首选正文）、ZCOOL 龙藏体 `Long Cang` / `Ma Shan Zheng`（标题/标注毛笔感）
  - 中文衬线/黑体：`Noto Serif SC` / `Noto Sans SC`（思源，OFL）
  - 英文：`Playfair Display` / `Cormorant`（衬线）、`Inter`（无衬线）、`Caveat`（手写点缀）
  - **CDN 坑**：中文字体整包几 MB，必须分包——中文走「中文网字计划」jsDelivr 包（`@chinese-fonts/xxx`），英文/思源走 Google Fonts（国内 `googlefonts.cn` 镜像）。截图前务必校验字体真渲染了。
- **信息密度**：图片承载视觉比喻/结构，解释性文字交给朋友圈文案；字要大（正文 ≥ 26px @1080 宽），受众用手机看。
- **内容填满画布**（2026-07-18 踩坑）：1080×1440 画布要被内容充分填满，避免大块留白。用 flex 布局让元素分布（如 `.steps{flex:1; justify-content:space-evenly}`），**署名用流式（flex 末尾）而非 `position:absolute`**——绝对定位的署名容易在内容和它之间留出大片空白。截图前用墨色占比校验内容是否铺满全画布。
- **对比性内容**：次要对比放角落灰调小卡片（`#f0ece4` 底），不与主体抢空间。
- **署名**：左下角「Khan驾到」（宋体 + 强调色短横线），右下角可放英文主题词。
- **标点**：中文语境用「」引号，不用 ""。注意避免标题/副标题出现孤行。

## 文案规范

- **长度**：默认目标 **60–90 字、≤6 行**，确保朋友圈不折叠完整显示（微信规则：手动输入 ≤200 字 / ≤6 行不折叠；复制粘贴超 ~100 字会触发灰底营销折叠）。**内容完整性优先于长度**——必要时允许超出、接受「全文」折叠，绝不为了压字数牺牲信息。
- 口语化、比喻先行，从受众（了解 AI 辅助开发但非专业）的认知出发；少用术语，多用具体场景。
- **第一人称个人语气**（2026-07-18 确认）：用「我……」、带情绪和体感，像在朋友圈说话，而不是写文案/产品说明。
- **反金句 / 反营销腔**（2026-07-18 确认）：避免工整对仗、押韵、口号化的句子（如「看一遍，强一分」这类）。宁可句子散一点、糙一点，也要像人话。
- **必须带真实个人细节**（2026-07-18 确认）：具体工具名、命令、路径、真实场景、使用体感或数字；不要停留在概念层面。细节是去 AI 味的关键。

## Git 工作流

当我说「提交代码」（或「commit」「提交」「推一下」等同类指令），按顺序执行，无需二次确认：
1. **先重新生成图片**：若本次会话改过某个话题的 `image.html`，先按工作流第 4 步重新导出该目录的 `image.png`（确保提交的是最新截图，而非过期版本）。
2. **commit**：把所有改动（含刚生成的 `image.png`）一起提交。
3. **立即 `git push`** 推送到 GitHub。

本仓库直接在 `main` 分支上工作并推送，不必另开分支。
