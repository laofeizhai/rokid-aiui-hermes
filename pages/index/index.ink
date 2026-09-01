<script def>
{
  "navigationBarTitleText": "Hermes"
}
</script>

<script setup>
import wx from 'wx';

const CFG = {
  ENDPOINT: "https://ai.ksflex.com",
  MODEL: "deepseek-v4-flash-vision-exp",
  TOKEN: "YOUR_BRIDGE_TOKEN_HERE",
};

export default {
  data: {
    input: '',
    answer: '你好，我是睿。输入问题后点发送，或用下方按钮：语音 / 拍照识图 / 翻译。',
    loading: false,
    model: CFG.MODEL,
  },

  onInput(e) {
    this.setData({ input: e.currentTarget.value });
  },

  onSend() {
    const text = (this.data.input || '').trim();
    if (!text) return;
    this.setData({ input: '' });
    this.ask(text);
  },

  async onVoice() {
    try {
      const rec = new SpeechRecognition();
      rec.lang = 'zh-CN';
      rec.interimResults = false;
      rec.onresult = (event) => {
        const res = event.results;
        const transcript = (res && res[event.resultIndex] && res[event.resultIndex][0] && res[event.resultIndex][0].transcript)
          ? res[event.resultIndex][0].transcript : '';
        if (transcript) this.ask(transcript);
      };
      rec.onerror = (e) => this.setData({ answer: '语音识别失败: ' + (e && e.error) });
      rec.start();
    } catch (err) {
      this.setData({ answer: '语音不可用: ' + (err && err.message) });
    }
  },

  async onPhoto() {
    try {
      const camera = wx.media.createCameraContext();
      const photo = await camera.takePhoto({ quality: 'high' });
      if (!photo || !photo.data) {
        this.setData({ answer: '拍照失败' });
        return;
      }
      const mime = photo.mimeType || 'image/jpeg';
      const imageUrl = 'data:' + mime + ';base64,' + wx.arrayBufferToBase64(photo.data);
      this.ask('帮我看一下这张照片，并告诉我它是什么。', imageUrl);
    } catch (err) {
      this.setData({ answer: '拍照不可用: ' + (err && err.message) });
    }
  },

  onTranslate() {
    const text = (this.data.input || '').trim();
    if (!text) { this.setData({ answer: '请先输入要翻译的内容' }); return; }
    this.setData({ input: '' });
    this.ask('把下面这段话翻译成中文，如果已经是中文则翻译成英文，只给译文：\n' + text);
  },

  ask(text, image) {
    this.setData({ loading: true, answer: '' });
    const content = [{ type: 'text', text }];
    if (image) content.push({ type: 'image_url', image_url: { url: image } });

    fetch(CFG.ENDPOINT + '/v1/chat/completions', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + CFG.TOKEN },
      body: JSON.stringify({ model: CFG.MODEL, messages: [{ role: 'user', content }] }),
    })
      .then((r) => { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
      .then((d) => {
        const reply = (d.choices && d.choices[0] && d.choices[0].message && d.choices[0].message.content) || '';
        this.setData({ loading: false, answer: reply });
        this.speak(reply);
      })
      .catch((err) => { this.setData({ loading: false, answer: '调用失败: ' + (err && err.message) }); });
  },

  speak(text) {
    try {
      if (typeof wx !== 'undefined' && wx.speech && wx.speech.playTTS) wx.speech.playTTS(text);
      else if (typeof speechSynthesis !== 'undefined' && speechSynthesis.speak) speechSynthesis.speak(new SpeechSynthesisUtterance(text));
    } catch (e) {}
  },
};
</script>

<page>
  <view class="card">
    <view class="head">
      <text class="model">{{model}}</text>
      <text class="status">{{loading ? '思考中…' : '● 待命'}}</text>
    </view>
    <view class="body">
      <text class="ans-text">{{answer}}</text>
    </view>
    <view class="inputbar">
      <input class="ipt" value="{{input}}" placeholder="输入问题…" bindinput="onInput" />
      <button class="send" bindtap="onSend">发送</button>
    </view>
    <view class="controls">
      <button class="btn" bindtap="onVoice">语音</button>
      <button class="btn" bindtap="onPhoto">拍照识图</button>
      <button class="btn" bindtap="onTranslate">翻译</button>
    </view>
  </view>
</page>

<style>
.card {
  width: 480px;
  max-height: 352px;
  display: flex;
  flex-direction: column;
  background: #0f1115;
  border: 2px solid #555;
  border-radius: 12px;
  padding: 12px;
  gap: 8px;
  box-sizing: border-box;
}
.head { display: flex; justify-content: space-between; align-items: center; }
.model { color: #9aa; font-size: 12px; }
.status { color: #40FF5E; font-size: 12px; }
.body { flex: 1; overflow: hidden; }
.ans-text { color: #fff; font-size: 16px; line-height: 1.5; }
.inputbar { display: flex; gap: 8px; }
.ipt { flex: 1; background: #1a1a1a; color: #fff; border: 1px solid #555; border-radius: 8px; padding: 8px 12px; font-size: 15px; }
.send { background: #40FF5E; color: #000; border-radius: 8px; font-size: 15px; padding: 0 20px; }
.controls { display: flex; gap: 8px; }
.btn { flex: 1; background: #1a1a1a; color: #fff; border: 1px solid #555; border-radius: 8px; font-size: 14px; padding: 8px 0; }
</style>
