# 🔐 Token 配置图解

## 📊 Token 流程图

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Token 认证流程                               │
└─────────────────────────────────────────────────────────────────────┘

第一步：H5 客户端连接到 ClawApp
┌──────────────┐                                    ┌──────────────┐
│              │  HTTP POST /api/connect            │              │
│  H5 客户端   │  {token: "my-clawapp-password"}   │   ClawApp    │
│  (浏览器)    │ ─────────────────────────────────▶ │   服务端     │
│              │                                    │              │
└──────────────┘                                    └──────────────┘
                                                           │
                                                           │ 验证 PROXY_TOKEN
                                                           ▼
                                                    ✅ 认证成功
                                                    创建会话


第二步：ClawApp 连接到 PicoClaw
                                                    ┌──────────────┐
                                                    │              │
                                                    │   ClawApp    │
                                                    │   服务端     │
                                                    │              │
                                                    └──────────────┘
                                                           │
                                                           │ WebSocket 连接
                                                           │ ws://localhost:18790/pico/ws
                                                           │ ?token=picoclaw-secret
                                                           ▼
                                                    ┌──────────────┐
                                                    │              │
                                                    │  PicoClaw    │
                                                    │  Gateway     │
                                                    │              │
                                                    └──────────────┘
                                                           │
                                                           │ 验证 token
                                                           ▼
                                                    ✅ 认证成功
                                                    建立连接
```

## 🔑 Token 配置对照表

### Token 1: PROXY_TOKEN

| 项目 | 说明 |
|------|------|
| **用途** | H5 客户端连接到 ClawApp 服务端 |
| **配置位置** | `server/.env` |
| **配置项** | `PROXY_TOKEN=xxx` |
| **使用场景** | 浏览器登录时输入 |
| **是否自己设置** | ✅ 是，完全自定义 |
| **示例** | `my-clawapp-password-123` |

### Token 2: PICOCLAW_GATEWAY_TOKEN

| 项目 | 说明 |
|------|------|
| **用途** | ClawApp 服务端连接到 PicoClaw Gateway |
| **配置位置** | `~/.picoclaw/config.json` 和 `server/.env` |
| **配置项** | PicoClaw: `channels.pico.token`<br>ClawApp: `PICOCLAW_GATEWAY_TOKEN` |
| **使用场景** | 服务端自动使用，用户无感知 |
| **是否自己设置** | ✅ 是，但必须两处一致 |
| **示例** | `a3f8d9e2c1b4567890abcdef` |

## 📝 配置示例

### PicoClaw 配置 (`~/.picoclaw/config.json`)

```json
{
  "channels": {
    "pico": {
      "enabled": true,
      "token": "a3f8d9e2c1b4567890abcdef"  // ← Token 2
    }
  }
}
```

### ClawApp 配置 (`server/.env`)

```bash
# Token 1: H5 客户端连接密码（自己设置）
PROXY_TOKEN=my-clawapp-password-123

# Token 2: PicoClaw 连接密码（必须与上面一致）
PICOCLAW_GATEWAY_TOKEN=a3f8d9e2c1b4567890abcdef
```

### 浏览器登录

```
服务器地址: localhost:3210
Token: my-clawapp-password-123  ← 输入 PROXY_TOKEN
```

## ✅ 检查清单

- [ ] PicoClaw 配置文件中设置了 `channels.pico.token`
- [ ] ClawApp `.env` 文件中设置了 `PICOCLAW_GATEWAY_TOKEN`
- [ ] 两个 Token 完全一致（包括大小写）
- [ ] ClawApp `.env` 文件中设置了 `PROXY_TOKEN`
- [ ] 浏览器登录时使用 `PROXY_TOKEN`

## 🎯 快速记忆

```
两个 Token，两个用途：

1️⃣ PROXY_TOKEN
   浏览器 → ClawApp
   你自己设置，浏览器登录时输入

2️⃣ PICOCLAW_GATEWAY_TOKEN
   ClawApp → PicoClaw
   你自己设置，但必须两处一致
```

## 🔧 生成 Token 命令

```bash
# 生成 PROXY_TOKEN（随意设置）
echo "my-clawapp-$(openssl rand -hex 8)"
# 输出: my-clawapp-a3f8d9e2c1b45678

# 生成 PICOCLAW_GATEWAY_TOKEN（推荐使用强密码）
openssl rand -hex 24
# 输出: a3f8d9e2c1b4567890abcdef12345678901234567890
```

## 📚 相关文档

- [完整 Token 指南](./TOKEN_GUIDE.md) - 详细说明和故障排查
- [快速开始](./QUICKSTART_PICOCLAW.md) - 5 分钟配置指南
- [配置指南](./PICOCLAW_SUPPORT.md) - 完整配置说明

---

**记住**: 两个 Token 都是你自己设置的，但 `PICOCLAW_GATEWAY_TOKEN` 需要在两个地方保持一致！
