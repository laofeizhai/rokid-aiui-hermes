// AIUI 应用入口：全局生命周期与数据（ES Module）
import cfg from './config.js';

export default {
  onLaunch() {
    console.log('[Hermes] AIUI agent launched');
  },
  onShow() {
    console.log('[Hermes] visible');
  },
  onHide() {
    console.log('[Hermes] hidden');
  },
  globalData: {
    endpoint: cfg.ENDPOINT,
    token: cfg.TOKEN,
    model: cfg.MODEL,
  },
};
