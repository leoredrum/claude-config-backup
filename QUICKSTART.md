# 快速恢复指南

## 🚀 新电脑一键恢复

```bash
# 1. 克隆配置
git clone https://github.com/leoredrum/claude-config-backup.git
cd claude-config-backup

# 2. 运行恢复脚本
./restore.sh

# 3. 编辑敏感信息
vim ~/.claude/settings.json
# 将 YOUR_AUTH_TOKEN_HERE 替换为实际 token

# 4. 确保 Ollama 运行
ollama serve

# 5. 重启 Claude Code
```

## ⚡ 30秒快速版

```bash
git clone https://github.com/leoredrum/claude-config-backup.git ~/claude-config-temp
cd ~/claude-temp
./restore.sh
# 编辑 ~/.claude/settings.json 填入 token
rm -rf ~/claude-config-temp
```

## 🔑 获取 API Token

你的 token 在旧电脑的 `~/.claude/settings.json` 中：

```bash
# 在旧电脑上查看
cat ~/.claude/settings.json | grep AUTH_TOKEN
```

复制整个 token 值到新电脑。

## ✅ 验证配置

```bash
# 检查 Ollama
curl http://localhost:11434/api/tags

# 检查配置语法
jq empty ~/.claude/settings.json
jq empty ~/.claude/.mcp.json

# 测试 Claude Code
claude --version
```

## 🎯 完成后的效果

- ✅ 所有任务自动用子 Agent
- ✅ 本地 qwen2.5-coder:32b 模型
- ✅ 中文界面
- ✅ 节省 70-90% API token

有问题查看完整 [README.md](README.md)
