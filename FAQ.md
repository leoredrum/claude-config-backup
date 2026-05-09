# 常见问题解答 (FAQ)

## 📚 目录

- [安装问题](#安装问题)
- [配置问题](#配置问题)
- [Ollama 问题](#ollama-问题)
- [子 Agent 问题](#子-agent-问题)
- [性能问题](#性能问题)
- [迁移问题](#迁移问题)
- [其他问题](#其他问题)

---

## 安装问题

### Q1: Homebrew 安装失败怎么办？

**症状**: `/bin/bash: No such file or directory`

**解决方案**:
```bash
# 方案 1: 使用 zsh
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 方案 2: 手动安装 curl
brew install curl

# 方案 3: 使用代理
export https_proxy=http://127.0.0.1:7890
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Q2: Ollama 安装后无法运行？

**症状**: `command not found: ollama`

**解决方案**:
```bash
# 添加到 PATH
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zprofile
source ~/.zprofile

# 验证
which ollama
```

### Q3: Claude Code 安装成功但无法启动？

**症状**: `claude: command not found`

**解决方案**:
```bash
# 重新链接
brew unlink claude-code && brew link claude-code

# 检查安装
brew list | grep claude

# 重启终端
exec $SHELL
```

### Q4: 模型下载太慢或失败？

**症状**: `pull failed` 或下载卡住

**解决方案**:
```bash
# 方案 1: 使用镜像
export OLLAMA_HOST=127.0.0.1:11434

# 方案 2: 分批下载（先下小模型）
ollama pull qwen2.5-coder:7b

# 方案 3: 使用代理
export https_proxy=http://127.0.0.1:7890
ollama pull qwen2.5-coder:32b

# 方案 4: 手动下载
# 从 https://ollama.com/library 下载
ollama create qwen2.5-coder:32b -f Modelfile
```

---

## 配置问题

### Q5: JSON 配置文件语法错误？

**症状**: `parse error: Expected ','`

**解决方案**:
```bash
# 使用 jq 验证
jq . ~/.claude/settings.json | less

# 常见错误：
# 1. 缺少逗号
{
  "key1": "value1"
  "key2": "value2"  # ← 这里应该有逗号
}

# 2. 多余的逗号
{
  "key1": "value1",  # ← 最后一个元素不应该有逗号
}

# 3. 括号不匹配
{
  "key1": "value1"
}  # ← 检查括号数量
```

### Q6: API Token 配置后仍然无效？

**症状**: `Authentication failed`

**解决方案**:
```bash
# 1. 确认 token 格式正确
cat ~/.claude/settings.json | grep AUTH_TOKEN
# 应该是类似: "366ed8d1857f4ab39ea028151a90107e.UPSwH2oBgC0Y3UNA"

# 2. 检查是否有额外空格
jq '.env.ANTHROPIC_AUTH_TOKEN' ~/.claude/settings.json

# 3. 重新登录
claude logout
claude login

# 4. 检查 BASE_URL
jq '.env.ANTHROPIC_BASE_URL' ~/.claude/settings.json
```

### Q7: 路径配置错误导致 hooks 不工作？

**症状**: `Notification hook failed`

**解决方案**:
```bash
# 1. 检查路径是否存在
ls -la ~/.claude/hooks/notify.sh

# 2. 检查文件权限
chmod +x ~/.claude/hooks/notify.sh

# 3. 更新配置中的路径
# 获取当前用户名
CURRENT_USER=$(whoami)

# 替换配置中的路径
sed -i '' "s|/Users/YOUR_USERNAME/|/Users/$CURRENT_USER/|g" ~/.claude/settings.json

# 4. 验证
test -x ~/.claude/hooks/notify.sh && echo "✓ Hooks 可执行" || echo "✗ Hooks 不可执行"
```

### Q8: npm 路径配置过期？

**症状**: `Plugin not found: zai-coding-plugins`

**解决方案**:
```bash
# 方案 1: 重新安装插件（推荐）
npm install -g @z_ai/coding-helper

# 方案 2: 查找新路径
find ~/.npm/_npx -name "zai-coding-plugins" 2>/dev/null | head -1

# 方案 3: 更新配置
# 路径会在首次运行时自动更新
# 或者手动删除 extraKnownMarketplaces 中的路径
```

---

## Ollama 问题

### Q9: Ollama 服务无法启动？

**症状**: `Failed to start Ollama`

**解决方案**:
```bash
# 1. 检查端口占用
lsof -i :11434

# 2. 杀死占用进程
killall ollama

# 3. 清理并重启
rm -rf ~/.ollama
ollama serve &

# 4. 使用 brew services
brew services restart ollama

# 5. 查看日志
tail -f ~/Library/Logs/Ollama/*.log
```

### Q10: 模型加载很慢？

**症状**: 等待很长时间才响应

**解决方案**:
```bash
# 方案 1: 使用量化模型
ollama pull qwen2.5-coder:32b-q4_0

# 方案 2: 预加载模型
ollama run qwen2.5-coder:32b "exit"

# 方案 3: 增加 Ollama 内存
export OLLAMA_NUM_GPU=1
export OLLAMA_MAX_LOADED_MODELS=1

# 方案 4: 使用更小的模型
ollama pull qwen2.5-coder:7b
```

### Q11: Ollama API 返回错误？

**症状**: `API error: model not found`

**解决方案**:
```bash
# 1. 检查已安装的模型
ollama list

# 2. 确认模型名称
# qwen2.5-coder:32b ≠ qwen2.5-coder-32b

# 3. 重新拉取
ollama pull qwen2.5-coder:32b

# 4. 测试 API
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5-coder:32b",
  "prompt": "test",
  "stream": false
}'
```

### Q12: Ollama 内存占用过高？

**症状**: 系统变慢，内存告警

**解决方案**:
```bash
# 1. 限制并发模型
export OLLAMA_MAX_LOADED_MODELS=1

# 2. 卸载不需要的模型
ollama rm qwen2.5-coder:32b
ollama pull qwen2.5-coder:7b

# 3. 监控内存使用
ollama ps

# 4. 设置 GPU 层数（如果有独立显卡）
export OLLAMA_NUM_GPU=1

# 5. 重启 Ollama
killall ollama && ollama serve &
```

---

## 子 Agent 问题

### Q13: 子 Agent 没有自动运行？

**症状**: 所有任务都由主 Agent 直接执行

**解决方案**:
```bash
# 1. 检查 workflow orchestrator 插件
cat ~/.claude/settings.json | grep workflow-orchestrator

# 应该看到：
# "workflow-orchestrator@barkain-plugins": true

# 2. 如果没有，手动添加
vim ~/.claude/settings.json
# 在 "enabledPlugins" 中添加：
# "workflow-orchestrator@barkain-plugins": true

# 3. 重启 Claude Code
killall claude && claude &
```

### Q14: 子 Agent 返回错误？

**症状**: `Subagent failed with error`

**解决方案**:
```bash
# 1. 查看子 Agent 日志
cat ~/.claude/logs/subagent-*.log

# 2. 检查 MCP 服务器
curl http://localhost:11434/api/tags

# 3. 重启 MCP 服务
killall ollama && ollama serve &

# 4. 验证配置
jq '.enabledMcpjsonServers' ~/.claude/settings.json
# 应该包含: ["ollama"]
```

### Q15: 子 Agent 使用的是 API 而不是本地模型？

**症状**: API token 消耗没有减少

**解决方案**:
```bash
# 1. 确认 Ollama 正常运行
curl -s http://localhost:11434/api/tags | jq .

# 2. 检查 MCP 配置
cat ~/.claude/.mcp.json

# 3. 验证环境变量
jq '.env.OLLAMA_MODEL' ~/.claude/settings.json
jq '.env.OLLAMA_HOST' ~/.claude/settings.json

# 4. 测试本地模型
ollama run qwen2.5-coder:32b "test"

# 5. 重启 Claude Code
killall claude && claude &
```

### Q16: 子 Agent 响应很慢？

**症状**: 等待时间过长

**解决方案**:
```bash
# 方案 1: 预加载模型
ollama run qwen2.5-coder:32b "exit"

# 方案 2: 使用更小的模型
# 修改 settings.json
{
  "env": {
    "OLLAMA_MODEL": "qwen2.5-coder:7b"
  }
}

# 方案 3: 调整超时时间
export API_TIMEOUT_MS=6000000

# 方案 4: 使用量化模型
ollama pull qwen2.5-coder:32b-q4_0
```

---

## 性能问题

### Q17: Token 消耗没有明显减少？

**症状**: API 账单变化不大

**解决方案**:
```bash
# 1. 确认子 Agent 正常工作
# 在 Claude Code 中输入：
> 用 Python 写一个斐波那契函数
# 应该看到：委托给子 agent

# 2. 检查 Ollama 使用情况
ollama ps

# 3. 监控 API 调用
# 查看：https://console.anthropic.com/dashboard

# 4. 对比测试
# 做同样任务，观察 token 变化

# 5. 查看日志
tail -f ~/.claude/logs/claude-code.log | grep -i agent
```

### Q18: 系统响应变慢？

**症状**: 整体性能下降

**解决方案**:
```bash
# 1. 检查内存使用
top -o mem

# 2. 检查 Ollama 进程
ps aux | grep ollama

# 3. 限制并发
export OLLAMA_MAX_LOADED_MODELS=1

# 4. 清理缓存
claude --clear-cache

# 5. 重启服务
killall ollama && killall claude
ollama serve &
claude &
```

### Q19: 某些任务比以前更慢？

**症状**: 特定任务变慢

**解决方案**:
```bash
# 原因分析：
# - 简单任务：子 Agent 开销 > 执行时间
# - 复杂任务：子 Agent 优势明显

# 解决方案：
# 1. 简单任务直接回答（不需要优化）
# 2. 复杂任务自动委托（已有优势）
# 3. 调整委托阈值（高级）
```

---

## 迁移问题

### Q20: 从旧电脑迁移配置失败？

**症状**: 配置无法应用

**解决方案**:
```bash
# 1. 手动复制配置
mkdir -p ~/.claude/hooks
cp claude-settings-template.json ~/.claude/settings.json
cp .claude/.mcp.json ~/.claude/.mcp.json
cp .claude/hooks/notify.sh ~/.claude/hooks/notify.sh
chmod +x ~/.claude/hooks/notify.sh

# 2. 编辑配置
vim ~/.claude/settings.json
# 填入 token 和更新路径

# 3. 验证
jq empty ~/.claude/settings.json
jq empty ~/.claude/.mcp.json

# 4. 重启
killall claude && claude &
```

### Q21: 新电脑上模型丢失？

**症状**: `model not found`

**解决方案**:
```bash
# 1. 检查已安装模型
ollama list

# 2. 重新拉取
ollama pull qwen2.5-coder:32b

# 3. 如果网络问题
# 使用其他电脑下载后复制
# 模型位置：~/.ollama/models/

# 4. 验证
ollama run qwen2.5-coder:32b "test"
```

### Q22: 用户名不同导致路径错误？

**症状**: `File not found: /Users/olduser/.claude/...`

**解决方案**:
```bash
# 1. 获取新用户名
NEW_USER=$(whoami)

# 2. 批量替换
sed -i '' "s|/Users/olduser/|/Users/$NEW_USER/|g" ~/.claude/settings.json

# 3. 验证
grep "/Users/$NEW_USER/" ~/.claude/settings.json

# 4. 确保目录存在
mkdir -p /Users/$NEW_USER/.claude/hooks
```

---

## 其他问题

### Q23: 如何查看详细的运行日志？

**解决方案**:
```bash
# Claude Code 日志
tail -f ~/.claude/logs/claude-code.log

# SubAgent 日志
tail -f ~/.claude/logs/subagent-*.log

# MCP 服务器日志
tail -f ~/.claude/logs/mcp-*.log

# Ollama 日志
tail -f ~/Library/Logs/Ollama/*.log
```

### Q24: 如何完全重置配置？

**解决方案**:
```bash
# ⚠️ 警告：会删除所有配置

# 1. 停止所有服务
killall claude
killall ollama

# 2. 备份当前配置
cp -r ~/.claude ~/.claude.backup

# 3. 删除配置
rm -rf ~/.claude

# 4. 重新运行恢复脚本
cd claude-config-backup
./restore.sh

# 5. 重新配置
vim ~/.claude/settings.json
```

### Q25: 如何更新到最新版本？

**解决方案**:
```bash
# 更新 Claude Code
brew upgrade claude-code

# 更新 Ollama
brew upgrade ollama

# 更新配置仓库
cd ~/claude-config-backup
git pull

# 重新应用配置
./restore.sh

# 验证版本
claude --version
ollama --version
```

### Q26: 如何卸载？

**解决方案**:
```bash
# 卸载 Claude Code
brew uninstall claude-code

# 卸载 Ollama
brew uninstall ollama

# 删除配置
rm -rf ~/.claude

# 删除模型
rm -rf ~/.ollama

# 删除缓存
rm -rf ~/Library/Caches/claude-code
```

### Q27: 如何联系支持？

**解决方案**:
```bash
# 1. 查看文档
cat README.md

# 2. 查看日志
tail -f ~/.claude/logs/claude-code.log

# 3. 生成诊断报告
claude --diagnostic

# 4. 提交 Issue
# https://github.com/leoredrum/claude-config-backup/issues

# 5. 官方支持
# https://claude.ai/support
```

---

## 📞 获取更多帮助

如果以上 FAQ 没有解决你的问题：

1. **查看完整文档**
   - [安装指南](INSTALL_GUIDE.md)
   - [迁移清单](MIGRATION_CHECKLIST.md)
   - [配置摘要](CONFIG_SUMMARY.md)

2. **查看日志**
   ```bash
   tail -f ~/.claude/logs/claude-code.log
   ```

3. **验证配置**
   ```bash
   jq empty ~/.claude/settings.json
   ```

4. **测试连接**
   ```bash
   curl http://localhost:11434/api/tags
   ```

5. **提交问题**
   - GitHub Issues: https://github.com/leoredrum/claude-config-backup/issues
   - 包含：系统信息、错误日志、配置文件（脱敏）

---

**最后更新**: 2026-05-10
