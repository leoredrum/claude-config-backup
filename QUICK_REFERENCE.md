# 快速参考卡片

## 🔑 关键信息

### GitHub 仓库
```
https://github.com/leoredrum/claude-config-backup
```

### 核心配置
- **模型**: qwen2.5-coder:32b (Ollama)
- **API**: http://localhost:11434
- **Token 节省**: 70-90%
- **语言**: 中文界面

## ⚡ 30 秒恢复

```bash
git clone https://github.com/leoredrum/claude-config-backup.git
cd claude-config-backup && ./restore.sh
vim ~/.claude/settings.json  # 填入 token
ollama serve && claude
```

## 📝 必须配置

### 1. API Token
从旧电脑获取：
```bash
cat ~/.claude/settings.json | grep AUTH_TOKEN
```

### 2. 用户路径
```bash
sed -i '' "s|/Users/YOUR_USERNAME/|/Users/$(whoami)/|g" ~/.claude/settings.json
```

### 3. Ollama 模型
```bash
ollama pull qwen2.5-coder:32b
```

## 🔧 常用命令

### 验证配置
```bash
# JSON 语法
jq empty ~/.claude/settings.json

# Ollama 连接
curl http://localhost:11434/api/tags

# 模型测试
ollama run qwen2.5-coder:32b "测试"
```

### 重启服务
```bash
# 重启 Ollama
killall ollama && ollama serve &

# 重启 Claude Code
killall claude && claude &

# 清理缓存
claude --clear-cache
```

### 查看日志
```bash
# Claude Code
tail -f ~/.claude/logs/claude-code.log

# Ollama
tail -f ~/Library/Logs/Ollama/*.log

# MCP 服务器
tail -f ~/.claude/logs/mcp-*.log
```

## 🎯 特性验证

### ✅ 子 Agent 工作
输入：`> 用 Python 写个 Hello World`
应该看到：`委托给子 agent`

### ✅ 本地模型
输入：`> 解释递归`
应该：快速响应，无 API 调用

### ✅ 中文界面
应该：看到中文 spinner（搞定中、行动中...）

## 📊 性能指标

| 指标 | 配置前 | 配置后 | 改善 |
|------|--------|--------|------|
| 主 Agent Token | 100% | 10% | 90% ↓ |
| 子 Agent Token | 0% | 0% | 本地 |
| 总 Token 消耗 | 100% | 10-30% | 70-90% ↓ |
| 响应速度 | 网络延迟 | 本地速度 | 更快 |

## 🆘 快速修复

### Ollama 连接失败
```bash
killall ollama && ollama serve &
```

### JSON 语法错误
```bash
jq . ~/.claude/settings.json | less
```

### 子 Agent 不工作
```bash
cat ~/.claude/settings.json | grep workflow-orchestrator
# 应该看到: "workflow-orchestrator@barkain-plugins": true
```

### 路径错误
```bash
sed -i '' "s|旧用户名|$(whoami)|g" ~/.claude/settings.json
```

## 📚 完整文档

- [README.md](README.md) - 完整说明
- [INSTALL_GUIDE.md](INSTALL_GUIDE.md) - 安装指南
- [MIGRATION_CHECKLIST.md](MIGRATION_CHECKLIST.md) - 迁移清单
- [FAQ.md](FAQ.md) - 常见问题
- [CONFIG_SUMMARY.md](CONFIG_SUMMARY.md) - 配置摘要
- [QUICKSTART.md](QUICKSTART.md) - 快速开始
- [CHANGELOG.md](CHANGELOG.md) - 更新日志

## 🔄 更新配置

```bash
cd ~/claude-config-backup
git pull
./restore.sh
```

## 🎉 完成确认

当你看到：
- ✅ 中文 spinner
- ✅ "委托给子 agent"
- ✅ 快速响应
- ✅ Token 减少

说明配置成功！

---

**最后更新**: 2026-05-10
**仓库**: https://github.com/leoredrum/claude-config-backup
