# ClawApp + PicoClaw 快速开始

5 分钟内让 ClawApp 连接到 PicoClaw！

## 📋 前置要求

- Node.js 18+
- PicoClaw 已安装并运行

## 🚀 快速步骤

### 1. 安装依赖

```bash
# 克隆项目（如果还没有）
git clone https://github.com/qingchencloud/clawapp.git
cd clawapp

# 安装依赖
npm ci
cd h5 && npm ci && cd ..
cd server && npm ci && cd ..
```

### 2. 构建 H5 前端

```bash
npm run build:h5
```

### 3. 配置 PicoClaw

编辑 PicoClaw 配置文件 `~/.picoclaw/config.json`：

```json
{
  "channels": {
    "pico": {
      "enabled": true,
      "token": "my-secret-token-123",  // ← 自己设置一个密码
      "allow_origins": ["*"]
    }
  },
  "gateway": {
    "host": "127.0.0.1",
    "port": 18790
  }
}
```

> 💡 **重要**: `token` 是你自己设置的密码，可以是任意字符串。建议使用强密码，例如：
> ```bash
> # 生成随机 token
> openssl rand -hex 16
> # 或者
> uuidgen
> ```

### 4. 启动 PicoClaw

```bash
picoclaw gateway
```

你应该看到类似的输出：

```
✓ Gateway started on 127.0.0.1:18790
✓ Channels enabled: [pico]
```

### 5. 配置 ClawApp

复制并编辑配置文件：

```bash
cp server/.env.example server/.env
```

编辑 `server/.env`：

```bash
# 后端类型
BACKEND_TYPE=picoclaw

# ClawApp 代理服务端配置
PROXY_PORT=3210
PROXY_TOKEN=clawapp-token-456  // ← 自己设置，用于 H5 客户端连接

# PicoClaw 配置
PICOCLAW_GATEWAY_URL=ws://127.0.0.1:18790/pico/ws
PICOCLAW_GATEWAY_TOKEN=my-secret-token-123  // ← 必须与 PicoClaw config.json 中的 token 一致
```

> ⚠️ **注意**: `PICOCLAW_GATEWAY_TOKEN` 必须与 PicoClaw 配置文件中的 `channels.pico.token` 完全一致！

### 6. 启动 ClawApp 服务端

```bash
cd server
node index.js
```

你应该看到：

```
[INFO] 代理服务端已启动: http://0.0.0.0:3210
[INFO] 后端类型: PICOCLAW
[INFO] 架构: 手机 ←SSE+POST→ 代理服务端 ←WS→ PicoClaw(ws://127.0.0.1:18790/pico/ws)
```

### 7. 打开浏览器

访问 `http://localhost:3210`

输入连接信息：
- **服务器地址**: `localhost:3210`
- **Token**: `clawapp-token-456`

点击"连接"，开始聊天！

## ✅ 验证连接

### 测试脚本

运行测试脚本检查配置：

```bash
# Linux/Mac
bash test-picoclaw.sh

# Windows
test-picoclaw.bat
```

### 手动检查

1. **检查 PicoClaw Gateway**:
   ```bash
   curl http://localhost:18790/health
   ```

2. **检查 ClawApp 服务端**:
   ```bash
   curl http://localhost:3210/health
   ```

3. **查看日志**:
   - PicoClaw: 终端输出
   - ClawApp: 终端输出

## 🐛 常见问题

### 连接失败

**问题**: 浏览器显示"连接失败"

**解决**:
1. 确认 PicoClaw Gateway 正在运行
2. 检查 Token 是否匹配
3. 查看服务端日志

### Token 认证失败

**问题**: 提示"Token 认证失败"

**解决**:
1. 确认 `PICOCLAW_GATEWAY_TOKEN` 与 PicoClaw 配置中的 `token` 一致
2. 确认 `PROXY_TOKEN` 与浏览器输入的 Token 一致

### 消息发送失败

**问题**: 消息发送后没有响应

**解决**:
1. 检查 PicoClaw 是否配置了 LLM provider
2. 查看 PicoClaw 日志是否有错误
3. 确认 PicoClaw 的 model 配置正确

## 📱 移动端访问

### 同一 WiFi

1. 查看电脑 IP 地址：
   ```bash
   # Mac/Linux
   ifconfig | grep "inet " | grep -v 127.0.0.1
   
   # Windows
   ipconfig
   ```

2. 手机浏览器访问：`http://你的电脑IP:3210`

### 外网访问

使用 [cftunnel](https://github.com/qingchencloud/cftunnel) 快速开启 HTTPS 隧道：

```bash
# 安装 cftunnel
curl -fsSL https://raw.githubusercontent.com/qingchencloud/cftunnel/main/install.sh | bash

# 一键穿透
cftunnel quick 3210
```

## 🎉 完成！

现在你可以：
- 💬 发送消息与 AI 聊天
- 📱 在手机上使用
- 🌙 切换主题
- 🌐 切换语言

## 📚 下一步

- [完整配置指南](./PICOCLAW_SUPPORT.md)
- [PicoClaw 文档](https://github.com/sipeed/picoclaw)
- [ClawApp 使用指南](./README.md)

## 💡 提示

- PicoClaw 比 OpenClaw 更轻量，适合资源受限的环境
- 可以随时切换回 OpenClaw：设置 `BACKEND_TYPE=openclaw`
- 支持多个客户端同时连接

祝使用愉快！🚀
