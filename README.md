# Hermes × Rokid Glasses — AIUI 智能体

把 Rokid Glasses 自带的 AI 换成 **Hermes**（我）。眼镜端用 Rokid 官方 **AIUI** 框架（单文件 `.ink` SFC），请求经 HTTPS 发到 **Hermes 桥接端点**（`ai.ksflex.com`），由 `deepseek-v4-flash-vision-exp`（我）处理文字 + 图片，再回传到 HUD。

## 目录结构

```
aiui/
├─ AGENTS.md            # 智能体身份/能力清单
├─ app.json             # 页面路由 + 窗口
├─ app.js               # 应用生命周期(ES module)
├─ config.js            # 端点地址 + 访问令牌 + 模型名  ← 改这里即可换后端
├─ pages/index/index.ink # 单文件页面: 语音+拍照+文字 → 我的端点 → HUD
└─ .agents/skills/aiui-dev/  # AIUI 官方开发技能(规范/API 参考)
```

## 功能（index.ink）

- **文字问答**：输入框 → `fetch` → 我的端点 → 答案 + 朗读
- **语音提问**：`SpeechRecognition`(ASR) → 文字 → 我的端点
- **拍照提问**：`wx.media.createCameraContext().takePhoto({quality:'high'})` → base64 → 我的端点(多模态)
- **朗读**：`speechSynthesis.speak`(原生 TTS)

## 关键配置（config.js）

```js
ENDPOINT: "https://ai.ksflex.com"   // 我的端点(稳定域名, 自动续期证书)
TOKEN:    "<ROKID_BRIDGE_TOKEN>"    // 访问令牌(~/.hermes/rokid-bridge/.env)
MODEL:    "deepseek-v4-flash-vision-exp"
```

## 我这边（服务器端）已完成并验证

- 桥接服务：`~/.hermes/rokid-bridge/server.py`（FastAPI，OpenAI 兼容 `/v1/chat/completions`）
- 鉴权：`Authorization: Bearer <TOKEN>`（无令牌 → 401）
- 公网：Caddy + Let's Encrypt → `https://ai.ksflex.com` → 转发到 `127.0.0.1:18790`
- 验证：本地/公网/域名三重通过；文字 + 图片(多模态) 均正常

## 你这边（设备端）下一步（用 AIUI Studio，免安装）

> AIUI Studio = Rokid 在线 IDE（浏览器即可，内置模拟器，**无需真机/无需审核即可测试**）。中国站：https://aiui.rokid.com/space

1. 打开 AIUI Studio（https://aiui.rokid.com/space）→ 登录 Rokid 开发者账号 → **创建 AIUI Agent**。
2. 首次创建的 Agent 没绑定项目，会弹"加载失败"——**属正常**，关掉即可。
3. **绑定本项目**（二选一）：
   - 方式一：关掉弹窗后**直接上传本项目**（`aiui/` 目录）绑定；
   - 方式二：编辑器设置 → 本地管理 → 绑定对应 AIUI 智能体。
4. 上传后设置**权限**，右侧**填写对 Agent 的描述**。
5. **⚠️ 提审必改图标**：把 `assets/icon.png`（已生成的"睿"图标）设为 Agent 图标——**不能用默认图标提审**。
6. 在 **Web 模拟器**点"运行智能体"调试：会模拟"唤醒→语音识别→大语言模型→语音播报"全过程，右侧有模拟返回/单击/前后滑动的按钮。**先测文字问答，再测语音/拍照。**
7. 调试通过后**提交审核**；审核通过**设为默认助手**（或按平台流程接入眼镜真机）。

### 注意
- 眼镜联网走**蓝牙→手机 App→公网**；`https://ai.ksflex.com` 必须能被手机/眼镜访问到。
- 令牌是共享密钥，**别提交到公开仓库**。
- 新增 `assets/icon.png`（512×512，"睿"图标）——提审要用自定义图标。

## 说明 / 注意

- 这是**开发版**；`.ink` 里的 ASR/拍照/TTS 用的是 AIUI 官方 API（`aiui-dev` 技能）。
- 令牌是共享密钥，别提交到公开仓库。
- 眼镜无本地 TTS 时，朗读走 `speechSynthesis`（若宿主不支持则静默跳过）。
