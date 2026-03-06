/**
 * PicoClaw 协议适配器
 * 
 * 将 ClawApp 的请求转换为 PicoClaw Pico Protocol 格式
 */

import { randomUUID } from 'crypto';
import { WebSocket } from 'ws';

export class PicoClawAdapter {
  constructor(gatewayUrl, token, log) {
    this.gatewayUrl = gatewayUrl;
    this.token = token;
    this.log = log;
    this.ws = null;
    this.sessionId = randomUUID();
    this.pending = new Map();
    this.eventHandlers = [];
    this.connected = false;
    this.reconnectTimer = null;
    this.pingTimer = null;
  }

  /**
   * 连接到 PicoClaw Gateway
   */
  async connect() {
    return new Promise((resolve, reject) => {
      const url = `${this.gatewayUrl}?token=${encodeURIComponent(this.token)}&session_id=${this.sessionId}`;
      this.log.info(`[PicoClaw] Connecting to ${this.gatewayUrl.split('?')[0]}...`);

      try {
        this.ws = new WebSocket(url);
      } catch (err) {
        return reject(new Error(`Failed to create WebSocket: ${err.message}`));
      }

      const timeout = setTimeout(() => {
        this.ws?.close();
        reject(new Error('Connection timeout'));
      }, 10000);

      this.ws.on('open', () => {
        clearTimeout(timeout);
        this.connected = true;
        this.log.info('[PicoClaw] Connected successfully');
        this.startPing();
        
        // 发送 ping 测试连接
        this.sendPing().then(() => {
          resolve({
            hello: {
              protocol: 'pico',
              version: '1.0.0',
              capabilities: ['chat', 'streaming'],
            },
            snapshot: {
              sessionDefaults: {
                mainSessionKey: this.sessionId,
              },
            },
          });
        }).catch(reject);
      });

      this.ws.on('message', (data) => {
        try {
          const msg = JSON.parse(data.toString());
          this.handleMessage(msg);
        } catch (err) {
          this.log.error('[PicoClaw] Failed to parse message:', err);
        }
      });

      this.ws.on('error', (err) => {
        this.log.error('[PicoClaw] WebSocket error:', err.message);
        if (!this.connected) {
          clearTimeout(timeout);
          reject(err);
        }
      });

      this.ws.on('close', (code, reason) => {
        this.connected = false;
        this.stopPing();
        this.log.warn(`[PicoClaw] Connection closed: ${code} ${reason}`);
        
        // 清理所有待处理的请求
        for (const [id, { reject }] of this.pending) {
          reject(new Error('Connection closed'));
        }
        this.pending.clear();
      });
    });
  }

  /**
   * 处理收到的消息
   */
  handleMessage(msg) {
    // 处理 pong 响应
    if (msg.type === 'pong') {
      const handler = this.pending.get(msg.id);
      if (handler) {
        clearTimeout(handler.timer);
        this.pending.delete(msg.id);
        handler.resolve();
      }
      return;
    }

    // 处理服务端消息
    if (msg.type === 'message.create' || msg.type === 'message.update') {
      const content = msg.payload?.content || '';
      const messageId = msg.payload?.message_id || msg.id;
      
      // 转换为 ClawApp 事件格式
      this.emitEvent({
        type: 'event',
        event: 'chat.stream',
        data: {
          sessionKey: msg.session_id || this.sessionId,
          runId: messageId,
          chunk: {
            type: 'text',
            text: content,
          },
          done: msg.type === 'message.create',
        },
      });
      return;
    }

    // 处理打字指示器
    if (msg.type === 'typing.start' || msg.type === 'typing.stop') {
      this.emitEvent({
        type: 'event',
        event: msg.type === 'typing.start' ? 'chat.thinking' : 'chat.ready',
        data: {
          sessionKey: msg.session_id || this.sessionId,
        },
      });
      return;
    }

    // 处理错误
    if (msg.type === 'error') {
      this.log.error('[PicoClaw] Server error:', msg.payload);
      this.emitEvent({
        type: 'event',
        event: 'chat.error',
        data: {
          sessionKey: msg.session_id || this.sessionId,
          error: {
            code: msg.payload?.code || 'unknown',
            message: msg.payload?.message || 'Unknown error',
          },
        },
      });
    }
  }

  /**
   * 发送 ping
   */
  async sendPing() {
    const id = randomUUID();
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        this.pending.delete(id);
        reject(new Error('Ping timeout'));
      }, 5000);

      this.pending.set(id, { resolve, reject, timer });

      this.ws.send(JSON.stringify({
        type: 'ping',
        id,
      }));
    });
  }

  /**
   * 启动心跳
   */
  startPing() {
    this.stopPing();
    this.pingTimer = setInterval(() => {
      if (this.connected) {
        this.sendPing().catch((err) => {
          this.log.error('[PicoClaw] Ping failed:', err.message);
        });
      }
    }, 30000);
  }

  /**
   * 停止心跳
   */
  stopPing() {
    if (this.pingTimer) {
      clearInterval(this.pingTimer);
      this.pingTimer = null;
    }
  }

  /**
   * 发送聊天消息
   */
  async sendMessage(sessionKey, content) {
    if (!this.connected) {
      throw new Error('Not connected');
    }

    const messageId = randomUUID();
    
    this.ws.send(JSON.stringify({
      type: 'message.send',
      id: messageId,
      session_id: sessionKey || this.sessionId,
      payload: {
        content,
      },
    }));

    // PicoClaw 通过 message.create 事件返回响应，不需要等待
    return { runId: messageId };
  }

  /**
   * 获取会话历史（PicoClaw 不支持，返回空）
   */
  async getHistory(sessionKey) {
    return { messages: [] };
  }

  /**
   * 中止请求（PicoClaw 暂不支持）
   */
  async abort(sessionKey, runId) {
    this.log.warn('[PicoClaw] Abort not supported');
  }

  /**
   * 注册事件监听器
   */
  on(handler) {
    this.eventHandlers.push(handler);
  }

  /**
   * 触发事件
   */
  emitEvent(event) {
    for (const handler of this.eventHandlers) {
      try {
        handler(event);
      } catch (err) {
        this.log.error('[PicoClaw] Event handler error:', err);
      }
    }
  }

  /**
   * 断开连接
   */
  disconnect() {
    this.stopPing();
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
    this.connected = false;
  }

  /**
   * 检查是否已连接
   */
  isConnected() {
    return this.connected && this.ws?.readyState === 1;
  }
}
