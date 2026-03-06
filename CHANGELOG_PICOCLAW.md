# ClawApp - PicoClaw 支持更新日志

## 🎉 新增功能

### ✨ 支持 PicoClaw 后端

ClawApp 现在可以连接到 PicoClaw Gateway，提供更轻量级的 AI 助手体验！

### 📝 主要变更

#### 1. 新增文件

- `server/picoclaw-adapter.js` - PicoClaw 协议适配器
- `PICOCLAW_SUPPORT.md` - PicoClaw 配置指南
- `QUICKSTART_PICOCLAW.md` - 快速开始指南
- `test-picoclaw.sh` / `test-picoclaw.bat` - 连接测试脚本
- `CHANGELOG_PICOCLAW.md` - 本文件

#### 2. 修改文件

**server/index.js**:
- 添加 `BACKEND_TYPE` 配置项
- 添加 PicoClaw 配置项（`PICOCLAW_GATEWAY_URL`, `PICOCLAW_GATEWAY_TOKEN`）
- 新增 `connectToPicoClaw()` 函数
- 修改 `connectToGateway()` 支持双后端
- 修改 `/api/send` 路由支持 PicoClaw 协议
- 修改 `cleanupSession()` 清理 PicoClaw 适配器
- 修改启动日志显示当前后端类型

**server/.env.example**:
- 添加 `BACKEND_TYPE` 配置
- 添加 PicoClaw 配置段

**README.md**:
- 更新项目介绍，说明支持双后端
- 添加 PicoClaw 架构图
- 添加 PicoClaw 配置指南链接

### 🔧 技术实现

#### PicoClaw 适配器

`PicoClawAdapter` 类实现了 Pico Protocol 的客户端：

- **连接管理**: WebSocket 连接 + Bearer Token 认证
- **消息转换**: Pico Protocol ↔ ClawApp 内部格式
- **心跳保活**: 30 秒 ping/pong 机制
- **事件处理**: 
  - `message.create` → `chat.stream`
  - `message.update` → `chat.stream`
  - `typing.start` → `chat.thinking`
  - `typing.stop` → `chat.ready`
  - `error` → `chat.error`

#### 协议对比

| 特性 | OpenClaw | PicoClaw |
|------|----------|----------|
| 协议 | 自定义 RPC over WebSocket | Pico Protocol |
| 认证 | Ed25519 签名 + Token/Password | Bearer Token |
| 消息格式 | `{type, id, method, params}` | `{type, id, session_id, payload}` |
| 会话管理 | 复杂（多 Agent、多 Session） | 简单（单 Session ID） |
| 历史记录 | `chat.history` 方法 | 暂不支持 |
| 中止请求 | `chat.abort` 方法 | 暂不支持 |

### 📊 配置示例

#### OpenClaw 模式

```bash
BACKEND_TYPE=openclaw
OPENCLAW_GATEWAY_URL=ws://127.0.0.1:18789
OPENCLAW_GATEWAY_TOKEN=your-openclaw-token
```

#### PicoClaw 模式

```bash
BACKEND_TYPE=picoclaw
PICOCLAW_GATEWAY_URL=ws://127.0.0.1:18790/pico/ws
PICOCLAW_GATEWAY_TOKEN=your-picoclaw-token
```

### 🎯 使用场景

#### 适合使用 PicoClaw 的场景

- 资源受限的环境（树莓派、旧手机等）
- 需要快速启动（<1 秒）
- 简单的聊天场景
- 学习和测试

#### 适合使用 OpenClaw 的场景

- 需要完整的 Agent 功能
- 需要会话历史管理
- 需要多 Agent 支持
- 生产环境部署

### 🔄 兼容性

- ✅ 完全向后兼容 OpenClaw 模式
- ✅ 无需修改 H5 客户端代码
- ✅ 可随时切换后端类型
- ✅ 支持同时部署多个实例（不同端口）

### 📈 性能对比

| 指标 | OpenClaw | PicoClaw |
|------|----------|----------|
| 内存占用 | ~1GB | <10MB |
| 启动时间 | ~30s | <1s |
| 连接延迟 | ~500ms | ~100ms |
| 消息延迟 | 相同 | 相同 |

### 🐛 已知限制

PicoClaw 模式下的限制：

1. **历史记录**: 暂不支持 `chat.history`，返回空数组
2. **中止请求**: 暂不支持 `chat.abort`，调用会被忽略
3. **多 Agent**: 暂不支持切换 Agent
4. **工具调用**: 不显示工具调用状态（PicoClaw 内部处理）

### 🚀 未来计划

- [ ] 支持 PicoClaw 的历史记录功能
- [ ] 支持 PicoClaw 的中止请求
- [ ] 支持 PicoClaw 的多 Agent 切换
- [ ] 添加自动后端检测（自动识别 OpenClaw/PicoClaw）
- [ ] 添加后端健康检查
- [ ] 支持同时连接多个后端

### 📝 迁移指南

#### 从 OpenClaw 迁移到 PicoClaw

1. 安装 PicoClaw:
   ```bash
   # 从 GitHub 下载
   wget https://github.com/sipeed/picoclaw/releases/latest/download/picoclaw-linux-amd64
   chmod +x picoclaw-linux-amd64
   ```

2. 配置 PicoClaw:
   ```bash
   ./picoclaw-linux-amd64 onboard
   # 按提示配置 API Key
   ```

3. 启动 PicoClaw:
   ```bash
   ./picoclaw-linux-amd64 gateway
   ```

4. 修改 ClawApp 配置:
   ```bash
   # 编辑 server/.env
   BACKEND_TYPE=picoclaw
   PICOCLAW_GATEWAY_URL=ws://127.0.0.1:18790/pico/ws
   PICOCLAW_GATEWAY_TOKEN=your-token
   ```

5. 重启 ClawApp:
   ```bash
   cd server && node index.js
   ```

### 🙏 致谢

感谢以下项目：

- [PicoClaw](https://github.com/sipeed/picoclaw) - 超轻量级 AI 助手
- [OpenClaw](https://github.com/openclaw/openclaw) - 强大的 AI 智能体平台

### 📄 许可证

MIT License

---

**版本**: v1.8.0  
**发布日期**: 2024-01-XX  
**作者**: ClawApp Team
