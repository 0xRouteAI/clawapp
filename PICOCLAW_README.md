# 🎉 ClawApp 现已支持 PicoClaw！

## 📝 修改总结

ClawApp 已成功集成 PicoClaw 支持，现在可以连接到两种 AI 后端：

- **OpenClaw**: 功能完整的 AI 智能体平台
- **PicoClaw**: 超轻量级 AI 助手（<10MB 内存）

## 🚀 快速开始

### 1. 配置 PicoClaw

编辑 `~/.picoclaw/config.json`:

```json
{
  "channels": {
    "pico": {
      "enabled": true,
      "token": "my-secret-token"
    }
  }
}
```

### 2. 启动 PicoClaw

```bash
picoclaw gateway
```

### 3. 配置 ClawApp

编辑 `server/.env`:

```bash
BACKEND_TYPE=picoclaw
PICOCLAW_GATEWAY_URL=ws://127.0.0.1:18790/pico/ws
PICOCLAW_GATEWAY_TOKEN=my-secret-token
PROXY_TOKEN=clawapp-token
```

### 4. 启动 ClawApp

```bash
npm run build:h5
cd server && node index.js
```

### 5. 打开浏览器

访问 `http://localhost:3210`，输入 Token 开始聊天！

## 📚 完整文档

| 文档 | 说明 |
|------|------|
| [PICOCLAW_SUPPORT.md](./PICOCLAW_SUPPORT.md) | 完整配置指南 |
| [QUICKSTART_PICOCLAW.md](./QUICKSTART_PICOCLAW.md) | 5 分钟快速开始 |
| [TOKEN_GUIDE.md](./TOKEN_GUIDE.md) | Token 配置详解 ⭐ |
| [CHANGELOG_PICOCLAW.md](./CHANGELOG_PICOCLAW.md) | 详细更新日志 |
| [PICOCLAW_INTEGRATION_SUMMARY.md](./PICOCLAW_INTEGRATION_SUMMARY.md) | 技术实现总结 |

## 🔧 测试工具

```bash
# Linux/Mac
bash test-picoclaw.sh

# Windows
test-picoclaw.bat
```

## ✨ 主要特性

- ✅ 支持 OpenClaw 和 PicoClaw 双后端
- ✅ 通过环境变量轻松切换
- ✅ 完整的聊天功能
- ✅ 实时流式响应
- ✅ 打字指示器
- ✅ 会话管理
- ✅ 离线缓存
- ✅ PWA 支持

## 📊 性能对比

| 指标 | OpenClaw | PicoClaw |
|------|----------|----------|
| 内存占用 | ~1GB | <10MB |
| 启动时间 | ~30s | <1s |
| 连接延迟 | ~500ms | ~100ms |

## 🎯 使用场景

### 选择 PicoClaw

- 资源受限环境（树莓派、旧手机）
- 快速启动需求
- 简单聊天场景
- 学习和测试

### 选择 OpenClaw

- 完整 Agent 功能
- 会话历史管理
- 多 Agent 支持
- 生产环境

## 🐛 故障排查

### 连接失败

1. 检查 PicoClaw 是否运行：`curl http://localhost:18790/health`
2. 检查 Token 是否匹配
3. 查看服务端日志

### 消息无响应

1. 检查 PicoClaw 的 LLM 配置
2. 查看 PicoClaw 日志：`picoclaw gateway -d`
3. 确认 model_list 配置正确

## 📱 移动端访问

### 同一 WiFi

```bash
# 查看电脑 IP
ifconfig | grep "inet " | grep -v 127.0.0.1  # Mac/Linux
ipconfig  # Windows

# 手机访问
http://你的电脑IP:3210
```

### 外网访问

使用 cftunnel 快速开启 HTTPS 隧道：

```bash
cftunnel quick 3210
```

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

---

**版本**: v1.8.0  
**更新日期**: 2024-01-XX  
**作者**: ClawApp Team

## 🔗 相关链接

- [ClawApp 主页](https://clawapp.qt.cool)
- [PicoClaw GitHub](https://github.com/sipeed/picoclaw)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [Discord 社区](https://discord.gg/U9AttmsNHh)

祝使用愉快！🚀
