// AIUI 智能体全局配置 —— 对接 Hermes "我的端点"（ES Module）
// 后端地址与令牌都在这里改，无需动页面代码。
export default {
  // 桥接服务稳定域名入口（Caddy + Let's Encrypt 自动续期）
  ENDPOINT: "https://ai.ksflex.com",
  // 访问令牌（~/.hermes/rokid-bridge/.env 里的 ROKID_BRIDGE_TOKEN）
  TOKEN: "YOUR_BRIDGE_TOKEN_HERE",
  // 模型展示名，仅提示用
  MODEL: "deepseek-v4-flash-vision-exp",
};
