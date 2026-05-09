#!/bin/bash

# Claude Code 配置恢复脚本
# 使用方法: ./restore.sh

set -e

echo "🚀 开始恢复 Claude Code 配置..."

# 1. 备份现有配置
echo "📦 备份现有配置..."
if [ -d ~/.claude ]; then
    BACKUP_DIR="$HOME/.claude.backup.$(date +%Y%m%d_%H%M%S)"
    cp -r ~/.claude "$BACKUP_DIR"
    echo "✓ 现有配置已备份到: $BACKUP_DIR"
fi

# 2. 创建必要的目录
echo "📁 创建目录结构..."
mkdir -p ~/.claude/hooks
mkdir -p ~/.claude/skills

# 3. 复制配置文件
echo "📋 复制配置文件..."

# 复制 settings 模板
if [ -f "claude-settings-template.json" ]; then
    echo "⚠️  需要手动配置 claude-settings-template.json"
    echo "   请编辑文件中的敏感信息（ANTHROPIC_AUTH_TOKEN、路径等）"
    echo "   然后运行: cp claude-settings-template.json ~/.claude/settings.json"
fi

# 复制其他配置
if [ -f ".claude/.mcp.json" ]; then
    cp .claude/.mcp.json ~/.claude/.mcp.json
    echo "✓ MCP 配置已恢复"
fi

if [ -f ".claude/settings.local.json" ]; then
    cp .claude/settings.local.json ~/.claude/settings.local.json
    echo "✓ 本地配置已恢复"
fi

# 复制 hooks
if [ -f ".claude/hooks/notify.sh" ]; then
    cp .claude/hooks/notify.sh ~/.claude/hooks/notify.sh
    chmod +x ~/.claude/hooks/notify.sh
    echo "✓ Hooks 脚本已恢复"
fi

# 复制 skills
if [ -d ".claude/skills" ] && [ "$(ls -A .claude/skills)" ]; then
    cp -r .claude/skills/* ~/.claude/skills/
    echo "✓ 自定义 skills 已恢复"
fi

# 4. 验证 JSON 语法
echo "🔍 验证配置文件..."
if command -v jq &> /dev/null; then
    if [ -f ~/.claude/settings.json ]; then
        jq empty ~/.claude/settings.json && echo "✓ settings.json 语法有效" || echo "✗ settings.json 语法错误"
    fi
    if [ -f ~/.claude/.mcp.json ]; then
        jq empty ~/.claude/.mcp.json && echo "✓ .mcp.json 语法有效" || echo "✗ .mcp.json 语法错误"
    fi
fi

echo ""
echo "✅ 配置恢复完成！"
echo ""
echo "📝 后续步骤："
echo "   1. 编辑 ~/.claude/settings.json，填入你的 ANTHROPIC_AUTH_TOKEN"
echo "   2. 根据新电脑的路径调整配置中的路径（如 username、npm 路径等）"
echo "   3. 确保 Ollama 已安装并运行: ollama serve"
echo "   4. 重启 Claude Code"
echo ""
echo "💾 如果出问题，备份在: $BACKUP_DIR"
