#!/bin/bash
# ClawApp PicoClaw 连接测试脚本

echo "🧪 ClawApp PicoClaw 连接测试"
echo "================================"

# 检查 PicoClaw Gateway
echo ""
echo "1️⃣ 检查 PicoClaw Gateway..."
if curl -s http://localhost:18790/health > /dev/null 2>&1; then
    echo "✅ PicoClaw Gateway 正在运行"
else
    echo "❌ PicoClaw Gateway 未运行"
    echo "   请先启动: picoclaw gateway"
    exit 1
fi

# 检查配置文件
echo ""
echo "2️⃣ 检查配置文件..."
if [ -f "server/.env" ]; then
    echo "✅ 找到 server/.env"
    
    # 检查后端类型
    BACKEND_TYPE=$(grep "^BACKEND_TYPE=" server/.env | cut -d'=' -f2)
    if [ "$BACKEND_TYPE" = "picoclaw" ]; then
        echo "✅ 后端类型: PicoClaw"
    else
        echo "⚠️  后端类型: $BACKEND_TYPE (不是 picoclaw)"
        echo "   请设置: BACKEND_TYPE=picoclaw"
    fi
    
    # 检查 Token
    PICOCLAW_TOKEN=$(grep "^PICOCLAW_GATEWAY_TOKEN=" server/.env | cut -d'=' -f2)
    if [ -n "$PICOCLAW_TOKEN" ] && [ "$PICOCLAW_TOKEN" != "your-picoclaw-token" ]; then
        echo "✅ PicoClaw Token 已配置"
    else
        echo "⚠️  PicoClaw Token 未配置"
        echo "   请设置: PICOCLAW_GATEWAY_TOKEN=your-token"
    fi
else
    echo "❌ 未找到 server/.env"
    echo "   请复制: cp server/.env.example server/.env"
    exit 1
fi

# 检查依赖
echo ""
echo "3️⃣ 检查依赖..."
if [ -d "server/node_modules" ]; then
    echo "✅ 服务端依赖已安装"
else
    echo "⚠️  服务端依赖未安装"
    echo "   运行: cd server && npm install"
fi

if [ -d "h5/node_modules" ]; then
    echo "✅ H5 依赖已安装"
else
    echo "⚠️  H5 依赖未安装"
    echo "   运行: cd h5 && npm install"
fi

# 检查构建
echo ""
echo "4️⃣ 检查 H5 构建..."
if [ -d "h5/dist" ]; then
    echo "✅ H5 已构建"
else
    echo "⚠️  H5 未构建"
    echo "   运行: npm run build:h5"
fi

echo ""
echo "================================"
echo "✨ 测试完成！"
echo ""
echo "启动命令:"
echo "  cd server && node index.js"
echo ""
echo "访问地址:"
echo "  http://localhost:3210"
