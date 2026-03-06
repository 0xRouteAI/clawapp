# ClawApp - PicoClaw 支持

ClawApp 现在支持连接到 PicoClaw Gateway！

## 🎯 功能特性

- ✅ 支持 OpenClaw 和 PicoClaw 双后端
- ✅ 通过环境变量切换后端类型
- ✅ 完整的聊天功能支持
- ✅ 实时流式响应
- ✅ 打字指示器
- ✅ 会话管理

## 📝 配置方法

### 1. 编辑 `server/.env` 文件

```bash
# 后端类型选择（openclaw 或 picoclaw）
BACKEND_TYPE=picoclaw

# PicoClaw Gateway 配置
PICOCLAW_GATEWAY_URL=ws://127.0.0.1:18790/pico/ws
PICOCLAW_GATEWAY_TOKEN=your-picoclaw-token  // ← 自己设置的密码

# ClawApp 代理服务端配置
PROXY_PORT=3210
PROXY_TOKEN=your-proxy-token  // ← 自己设置的密码
```

> 💡 **Token 说明**:
> - `PICOCLAW_GATEWAY_TOKEN`: 用于 ClawApp 连接到 PicoClaw，必须与 PicoClaw 配置中的 `channels.pico.token` 一致
> - `PROXY_TOKEN`: 用于 H5 客户端连接到 ClawApp 服务端，可以随意设置

### 2. 启动 PicoClaw Gateway

确保 PicoClaw Gateway 正在运行：

```bash
# 启动 PicoClaw
picoclaw gateway

# 默认监听端口: 18790
# Pico Protocol 端点: /pico/ws
```

### 3. 配置 PicoClaw Token

在 PicoClaw 的配置文件 `~/.picoclaw/config.json` 中设置 Pico Channel：

```json
{
  "channels": {
    "pico": {
      "enabled": true,
      "token": "your-picoclaw-token",  // ← 自己设置，与 PICOCLAW_GATEWAY_TOKEN 保持一致
      "allow_origins": ["*"],
      "max_connections": 100,
      "ping_interval": 30,
      "read_timeout": 60
    }
  },
  "gateway": {
    "host": "127.0.0.1",
    "port": 18790
  }
}
```

> 🔐 **生成强密码**:
> ```bash
> # 方法 1: 使用 openssl
> openssl rand -hex 24
> 
> # 方法 2: 使用 uuidgen
> uuidgen
> 
> # 方法 3: 使用 Node.js
> node -e "console.log(require('crypto').randomBytes(24).toString('hex'))"
> ```

### 4. 启动 ClawApp 服务端

```bash
cd server
npm install
node index.js
```

### 5. 使用 H5 客户端

打开浏览器访问 `http://localhost:3210`，输入：

- **服务器地址**: `localhost:3210`
- **Token**: `your-proxy-token`（你在 .env 中设置的 PROXY_TOKEN）

## 🔄 切换后端

### 切换到 PicoClaw

```bash
# 编辑 server/.env
BACKEND_TYPE=picoclaw
PICOCLAW_GATEWAY_URL=ws://127.0.0.1:18790/pico/ws
PICOCLAW_GATEWAY_TOKEN=your-picoclaw-token
```

### 切换到 OpenClaw

```bash
# 编辑 server/.env
BACKEND_TYPE=openclaw
OPENCLAW_GATEWAY_URL=ws://127.0.0.1:18789
OPENCLAW_GATEWAY_TOKEN=your-openclaw-token
```

重启 ClawApp 服务端即可生效。

## 📊 协议对比

| 特性 | OpenClaw | PicoClaw |
|------|----------|----------|
| 端口 | 18789 | 18790 |
| 协议 | 自定义 WebSocket | Pico Protocol |
| 认证 | Ed25519 签名 + Token | Bearer Token |
| 会话管理 | 复杂 | 简单 |
| 历史记录 | 支持 | 暂不支持 |
| 中止请求 | 支持 | 暂不支持 |

## 🐛 故障排查

### 连接失败

1. 检查 PicoClaw Gateway 是否运行：
   ```bash
   curl http://localhost:18790/health
   ```

2. 检查 Token 是否正确：
   ```bash
   # 查看 PicoClaw 配置
   cat ~/.picoclaw/config.json | grep -A 5 '"pico"'
   ```

3. 查看 ClawApp 日志：
   ```bash
   # 服务端日志会显示连接状态
   [INFO] [PicoClaw] Connecting to ws://127.0.0.1:18790/pico/ws...
   [INFO] [PicoClaw] Connected successfully
   ```

### 消息发送失败

1. 检查会话状态：
   ```bash
   curl http://localhost:3210/api/progress?sid=your-session-id
   ```

2. 查看 PicoClaw 日志：
   ```bash
   # PicoClaw 会显示收到的消息
   picoclaw gateway -d  # debug 模式
   ```

## 📚 相关文档

- [PicoClaw 官方文档](https://github.com/sipeed/picoclaw)
- [Pico Protocol 规范](https://github.com/sipeed/picoclaw/blob/main/pkg/channels/pico/protocol.go)
- [ClawApp 使用指南](./README.md)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License
