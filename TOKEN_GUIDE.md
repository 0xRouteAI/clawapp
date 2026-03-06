# 🔐 ClawApp + PicoClaw Token 配置指南

## 📋 Token 概述

在 ClawApp + PicoClaw 的架构中，有两个不同的 Token：

```
┌─────────────┐                    ┌──────────────┐                    ┌──────────────┐
│  H5 客户端  │ ─── PROXY_TOKEN ──▶│ ClawApp 服务端│ ─── PICOCLAW_TOKEN ──▶│ PicoClaw     │
│  (浏览器)   │                    │  (Node.js)   │                    │  Gateway     │
└─────────────┘                    └──────────────┘                    └──────────────┘
```

### Token 1: PROXY_TOKEN

**用途**: H5 客户端连接到 ClawApp 服务端的认证密码

**配置位置**: `server/.env`

```bash
PROXY_TOKEN=my-clawapp-password-123
```

**使用场景**: 
- 在浏览器打开 `http://localhost:3210` 时输入
- 防止未授权用户访问你的 ClawApp 服务端

**特点**:
- ✅ 完全由你自己设置
- ✅ 可以随时修改
- ✅ 与 PicoClaw 无关

### Token 2: PICOCLAW_GATEWAY_TOKEN

**用途**: ClawApp 服务端连接到 PicoClaw Gateway 的认证密码

**配置位置**: 
1. PicoClaw 配置文件 `~/.picoclaw/config.json`
2. ClawApp 配置文件 `server/.env`

**必须保持一致**:

```json
// ~/.picoclaw/config.json
{
  "channels": {
    "pico": {
      "token": "my-picoclaw-secret-456"  // ← 这里设置
    }
  }
}
```

```bash
# server/.env
PICOCLAW_GATEWAY_TOKEN=my-picoclaw-secret-456  // ← 必须与上面一致
```

**特点**:
- ✅ 完全由你自己设置
- ⚠️ 两个配置文件中必须完全一致
- ✅ 可以随时修改（需要同时修改两处）

## 🔧 配置步骤

### 步骤 1: 生成强密码

推荐使用随机生成的强密码：

```bash
# 方法 1: 使用 openssl（推荐）
openssl rand -hex 24
# 输出示例: a3f8d9e2c1b4567890abcdef12345678901234567890

# 方法 2: 使用 uuidgen
uuidgen
# 输出示例: 550e8400-e29b-41d4-a716-446655440000

# 方法 3: 使用 Node.js
node -e "console.log(require('crypto').randomBytes(24).toString('hex'))"
# 输出示例: 1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t

# 方法 4: 使用 Python
python3 -c "import secrets; print(secrets.token_hex(24))"
# 输出示例: 9f8e7d6c5b4a3210fedcba9876543210abcdef12
```

### 步骤 2: 配置 PicoClaw

编辑 `~/.picoclaw/config.json`:

```json
{
  "channels": {
    "pico": {
      "enabled": true,
      "token": "a3f8d9e2c1b4567890abcdef12345678901234567890",  // ← 粘贴生成的密码
      "allow_origins": ["*"]
    }
  },
  "gateway": {
    "host": "127.0.0.1",
    "port": 18790
  },
  "model_list": [
    {
      "model_name": "gpt4",
      "model": "openai/gpt-5.2",
      "api_key": "your-openai-api-key"
    }
  ]
}
```

### 步骤 3: 配置 ClawApp

编辑 `server/.env`:

```bash
# 后端类型
BACKEND_TYPE=picoclaw

# ClawApp 服务端端口
PROXY_PORT=3210

# H5 客户端连接密码（自己设置）
PROXY_TOKEN=my-clawapp-password-123

# PicoClaw Gateway 地址
PICOCLAW_GATEWAY_URL=ws://127.0.0.1:18790/pico/ws

# PicoClaw Gateway 密码（必须与 PicoClaw config.json 中的 token 一致）
PICOCLAW_GATEWAY_TOKEN=a3f8d9e2c1b4567890abcdef12345678901234567890
```

### 步骤 4: 启动服务

```bash
# 1. 启动 PicoClaw
picoclaw gateway

# 2. 启动 ClawApp
cd server && node index.js
```

### 步骤 5: 浏览器访问

1. 打开 `http://localhost:3210`
2. 输入连接信息：
   - **服务器地址**: `localhost:3210`
   - **Token**: `my-clawapp-password-123` （PROXY_TOKEN）
3. 点击"连接"

## ❌ 常见错误

### 错误 1: Token 不匹配

**症状**: 浏览器显示"连接失败"或"认证失败"

**原因**: `PICOCLAW_GATEWAY_TOKEN` 与 PicoClaw 配置中的 `token` 不一致

**解决**:
```bash
# 1. 检查 PicoClaw 配置
cat ~/.picoclaw/config.json | grep -A 3 '"pico"'

# 2. 检查 ClawApp 配置
cat server/.env | grep PICOCLAW_GATEWAY_TOKEN

# 3. 确保两者完全一致（包括大小写、空格）
```

### 错误 2: PROXY_TOKEN 错误

**症状**: 浏览器提示"Token 认证失败"

**原因**: 浏览器输入的 Token 与 `server/.env` 中的 `PROXY_TOKEN` 不一致

**解决**:
```bash
# 查看正确的 PROXY_TOKEN
cat server/.env | grep PROXY_TOKEN

# 在浏览器中输入完全一致的值
```

### 错误 3: Token 包含特殊字符

**症状**: 连接失败或出现奇怪的错误

**原因**: Token 中包含了 shell 或 JSON 的特殊字符（如 `$`, `"`, `\` 等）

**解决**: 使用纯字母数字和连字符的 Token
```bash
# 好的 Token 示例
a3f8d9e2c1b4567890abcdef
my-secret-token-123
550e8400-e29b-41d4-a716-446655440000

# 避免使用的字符
$ " ' \ ` & | ; < > ( ) { } [ ] * ? ! #
```

## 🔄 修改 Token

### 修改 PROXY_TOKEN

1. 编辑 `server/.env`:
   ```bash
   PROXY_TOKEN=new-password-456
   ```

2. 重启 ClawApp:
   ```bash
   cd server && node index.js
   ```

3. 浏览器重新连接，输入新的 Token

### 修改 PICOCLAW_GATEWAY_TOKEN

1. 编辑 `~/.picoclaw/config.json`:
   ```json
   {
     "channels": {
       "pico": {
         "token": "new-picoclaw-token-789"
       }
     }
   }
   ```

2. 编辑 `server/.env`:
   ```bash
   PICOCLAW_GATEWAY_TOKEN=new-picoclaw-token-789
   ```

3. 重启 PicoClaw:
   ```bash
   picoclaw gateway
   ```

4. 重启 ClawApp:
   ```bash
   cd server && node index.js
   ```

## 🔒 安全建议

### 1. 使用强密码

❌ 弱密码:
```
123456
password
admin
test
```

✅ 强密码:
```
a3f8d9e2c1b4567890abcdef12345678
550e8400-e29b-41d4-a716-446655440000
9f8e7d6c5b4a3210fedcba9876543210
```

### 2. 定期更换

建议每 3-6 个月更换一次 Token

### 3. 不要共享

- ❌ 不要将 Token 提交到 Git
- ❌ 不要在公共场合分享
- ❌ 不要在截图中暴露

### 4. 使用环境变量

生产环境建议使用环境变量而不是 `.env` 文件：

```bash
export PROXY_TOKEN="your-token"
export PICOCLAW_GATEWAY_TOKEN="your-picoclaw-token"
node server/index.js
```

### 5. 限制访问

如果部署到公网，建议：
- 使用 HTTPS
- 配置防火墙
- 使用 IP 白名单
- 启用访问日志

## 📝 配置模板

### 开发环境

```bash
# server/.env
BACKEND_TYPE=picoclaw
PROXY_PORT=3210
PROXY_TOKEN=dev-token-123
PICOCLAW_GATEWAY_URL=ws://127.0.0.1:18790/pico/ws
PICOCLAW_GATEWAY_TOKEN=dev-picoclaw-token-456
```

### 生产环境

```bash
# server/.env
BACKEND_TYPE=picoclaw
PROXY_PORT=3210
PROXY_TOKEN=a3f8d9e2c1b4567890abcdef12345678901234567890
PICOCLAW_GATEWAY_URL=ws://127.0.0.1:18790/pico/ws
PICOCLAW_GATEWAY_TOKEN=9f8e7d6c5b4a3210fedcba9876543210abcdef12
NODE_ENV=production
```

## 🧪 测试 Token 配置

### 测试脚本

```bash
#!/bin/bash

echo "🔐 测试 Token 配置"

# 1. 检查 PicoClaw Token
PICO_TOKEN=$(cat ~/.picoclaw/config.json | grep -A 3 '"pico"' | grep '"token"' | cut -d'"' -f4)
echo "PicoClaw Token: $PICO_TOKEN"

# 2. 检查 ClawApp Token
CLAW_TOKEN=$(cat server/.env | grep PICOCLAW_GATEWAY_TOKEN | cut -d'=' -f2)
echo "ClawApp Token: $CLAW_TOKEN"

# 3. 比较
if [ "$PICO_TOKEN" = "$CLAW_TOKEN" ]; then
    echo "✅ Token 配置正确！"
else
    echo "❌ Token 不匹配！"
    echo "   PicoClaw: $PICO_TOKEN"
    echo "   ClawApp:  $CLAW_TOKEN"
fi
```

### 手动测试

```bash
# 1. 测试 PicoClaw Gateway
curl -H "Authorization: Bearer your-picoclaw-token" \
     http://localhost:18790/health

# 2. 测试 ClawApp 服务端
curl http://localhost:3210/health

# 3. 查看日志
# PicoClaw 日志会显示连接状态
# ClawApp 日志会显示认证结果
```

## 📚 相关文档

- [快速开始指南](./QUICKSTART_PICOCLAW.md)
- [完整配置指南](./PICOCLAW_SUPPORT.md)
- [故障排查](./PICOCLAW_SUPPORT.md#故障排查)

## 💡 总结

记住这两个 Token 的区别：

1. **PROXY_TOKEN**: H5 客户端 → ClawApp 服务端（你自己设置）
2. **PICOCLAW_GATEWAY_TOKEN**: ClawApp 服务端 → PicoClaw Gateway（必须与 PicoClaw 配置一致）

两个 Token 都是你自己设置的，但 `PICOCLAW_GATEWAY_TOKEN` 需要在两个地方保持一致！

---

**提示**: 如果还有疑问，运行测试脚本检查配置：
```bash
bash test-picoclaw.sh  # Linux/Mac
test-picoclaw.bat      # Windows
```
