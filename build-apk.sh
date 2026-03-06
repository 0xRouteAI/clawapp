#!/bin/bash
# ClawApp APK 构建脚本

set -e

echo "🚀 开始构建 ClawApp APK..."

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ 错误: 未安装 Node.js"
    exit 1
fi

# 检查 Java
if ! command -v java &> /dev/null; then
    echo "❌ 错误: 未安装 Java JDK"
    exit 1
fi

echo "✓ 环境检查通过"

# 安装依赖
echo "📦 安装依赖..."
npm ci
cd h5 && npm ci && cd ..

# 构建 H5
echo "🔨 构建 H5 前端..."
npm run build:h5

# 同步到 Android
echo "🔄 同步到 Android 项目..."
npx cap sync android

# 构建 APK
echo "📱 构建 Debug APK..."
cd android
chmod +x gradlew
./gradlew assembleDebug

# 查找 APK
APK_PATH=$(find app/build/outputs/apk/debug -name "*.apk" | head -1)

if [ -n "$APK_PATH" ]; then
    echo ""
    echo "✅ 构建成功！"
    echo "📦 APK 位置: $APK_PATH"
    echo ""
    echo "安装命令:"
    echo "  adb install -r $APK_PATH"
else
    echo "❌ 构建失败: 未找到 APK 文件"
    exit 1
fi
