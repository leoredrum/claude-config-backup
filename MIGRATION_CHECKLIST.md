# 迁移检查清单 - 从旧电脑到新电脑

## 📋 迁移前准备（在旧电脑上）

### 1. 收集必要信息

- [ ] **复制 API Token**
  ```bash
  cat ~/.claude/settings.json | grep "ANTHROPIC_AUTH_TOKEN" | head -1
  ```
  保存到安全的地方（密码管理器）

- [ ] **记录用户名**
  ```bash
  whoami
  ```
  例如：`leo`

- [ ] **记录已安装的 Ollama 模型**
  ```bash
  ollama list
  ```
  保存列表

- [ ] **导出配置文件**（如果本仓库不可用）
  ```bash
  mkdir -p ~/claude-export
  cp ~/.claude/settings.json ~/claude-export/
  cp ~/.claude/.mcp.json ~/claude-export/
  cp ~/.claude/settings.local.json ~/claude-export/
  cp -r ~/.claude/hooks ~/claude-export/
  cp -r ~/.claude/skills ~/claude-export/
  tar czf ~/claude-export.tar.gz ~/claude-export/
  ```

- [ ] **截图当前配置**
  - Claude Code 版本: `claude --version`
  - Ollama 版本: `ollama --version`
  - 系统信息: `sw_vers`

### 2. 验证旧电脑配置

- [ ] **配置文件语法正确**
  ```bash
  jq empty ~/.claude/settings.json && echo "✓ settings.json OK"
  jq empty ~/.claude/.mcp.json && echo "✓ .mcp.json OK"
  ```

- [ ] **Ollama 服务正常**
  ```bash
  curl -s http://localhost:11434/api/tags | jq . && echo "✓ Ollama OK"
  ```

- [ ] **模型可以正常使用**
  ```bash
  ollama run qwen2.5-coder:32b "测试" && echo "✓ 模型 OK"
  ```

### 3. 备份重要数据

- [ ] **备份 memory 目录**
  ```bash
  cp -r ~/.claude/projects ~/claude-memory-backup
  ```

- [ ] **备份自定义 skills**
  ```bash
  cp -r ~/.claude/skills ~/claude-skills-backup
  ```

- [ ] **备份项目配置**
  ```bash
  # 如果有项目级别的 .claude 目录
  find ~/projects -name ".claude" -type d
  ```

## 🚀 迁移步骤（在新电脑上）

### 步骤 1: 系统准备

- [ ] **检查系统要求**
  - [ ] macOS 版本 ≥ 12.0 (`sw_vers`)
  - [ ] 内存 ≥ 16GB (`system_profiler SPHardwareDataType`)
  - [ ] 磁盘空间 ≥ 50GB (`df -h`)

- [ ] **安装 Xcode Command Line Tools**
  ```bash
  xcode-select --install
  ```

- [ ] **安装 Homebrew**
  ```bash
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```

### 步骤 2: 安装依赖

- [ ] **安装 Ollama**
  ```bash
  brew install ollama
  ollama --version
  ```

- [ ] **安装 Claude Code**
  ```bash
  brew install claude-code
  claude --version
  ```

- [ ] **安装 jq**（用于 JSON 处理）
  ```bash
  brew install jq
  jq --version
  ```

### 步骤 3: 配置 Ollama

- [ ] **启动 Ollama 服务**
  ```bash
  ollama serve &
  ```

- [ ] **拉取模型**
  ```bash
  ollama pull qwen2.5-coder:32b
  ```

- [ ] **验证模型**
  ```bash
  ollama list | grep qwen2.5-coder
  ```

- [ ] **测试模型**
  ```bash
  ollama run qwen2.5-coder:32b "你好"
  ```

### 步骤 4: 克隆配置

- [ ] **克隆配置仓库**
  ```bash
  git clone https://github.com/leoredrum/claude-config-backup.git
  cd claude-config-backup
  ```

- [ ] **检查文件**
  ```bash
  ls -la
  ```

- [ ] **运行恢复脚本**
  ```bash
  ./restore.sh
  ```

### 步骤 5: 配置敏感信息

- [ ] **获取新用户名**
  ```bash
  whoami
  ```

- [ ] **编辑 settings.json**
  ```bash
  vim ~/.claude/settings.json
  ```

  **必须修改**：
  1. `ANTHROPIC_AUTH_TOKEN` → 填入旧电脑的 token
  2. `/Users/YOUR_USERNAME/` → 改为新用户名
  3. `OLLAMA_HOST` → 确认是 `http://localhost:11434`

- [ ] **更新 hooks 路径**
  ```bash
  # 替换所有旧路径
  sed -i '' 's|/Users/YOUR_USERNAME/|'/Users/$(whoami)/'|g' ~/.claude/settings.json
  ```

- [ ] **验证 JSON**
  ```bash
  jq empty ~/.claude/settings.json
  jq empty ~/.claude/.mcp.json
  ```

### 步骤 6: 恢复额外数据

- [ ] **恢复 memory**（如果有备份）
  ```bash
  # 从旧电脑复制
  scp old-computer:~/claude-memory-backup ~/.claude/projects/
  ```

- [ ] **恢复 skills**（如果有备份）
  ```bash
  # 从旧电脑复制
  scp -r old-computer:~/claude-skills-backup/* ~/.claude/skills/
  ```

### 步骤 7: 最终验证

- [ ] **验证 Ollama 连接**
  ```bash
  curl -s http://localhost:11434/api/tags | jq .
  ```

- [ ] **验证配置文件**
  ```bash
  ls -la ~/.claude/
  ```

- [ ] **启动 Claude Code**
  ```bash
  claude
  ```

- [ ] **测试简单对话**
  ```
  > 你好
  ```

- [ ] **测试代码任务**（应该自动用子 Agent）
  ```
  > 用 Python 写一个 Hello World
  ```

- [ ] **测试本地模型**
  ```
  > 解释一下什么是递归
  ```

## ✅ 验证清单

### 基础功能

- [ ] Claude Code 可以启动
- [ ] 简单对话正常
- [ ] 中文 spinner 显示正常
- [ ] 没有错误日志

### 子 Agent 功能

- [ ] 代码任务自动委托给子 Agent
- [ ] 看到"委托给子 agent"的提示
- [ ] 返回精简结果（不是完整上下文）
- [ ] 使用本地模型（无 API 调用）

### Ollama 集成

- [ ] Ollama 服务运行中
- [ ] qwen2.5-coder:32b 模型可用
- [ ] 可以通过 MCP 调用
- [ ] 响应速度正常

### 配置文件

- [ ] settings.json 语法正确
- [ ] .mcp.json 语法正确
- [ ] settings.local.json 存在
- [ ] hooks 脚本可执行
- [ ] API Token 已配置
- [ ] 路径已更新

### 性能指标

- [ ] Token 消耗降低（对比旧电脑）
- [ ] 响应速度正常
- [ ] 内存使用合理
- [ ] CPU 使用正常

## 🔧 常见问题速查

### Token 相关

**问题**: API token 无效
```bash
# 解决：重新配置
vim ~/.claude/settings.json
# 检查 ANTHROPIC_AUTH_TOKEN 字段
```

**问题**: Token 消耗没有减少
```bash
# 解决：检查子 Agent 配置
cat ~/.claude/settings.json | grep workflow-orchestrator
# 应该看到 "workflow-orchestrator@barkain-plugins": true
```

### Ollama 相关

**问题**: 模型加载失败
```bash
# 解决：重新拉取
ollama pull qwen2.5-coder:32b
```

**问题**: Ollama 连接失败
```bash
# 解决：重启服务
killall ollama && ollama serve &
```

### 配置相关

**问题**: JSON 语法错误
```bash
# 解决：使用 jq 验证并修复
jq . ~/.claude/settings.json | less
```

**问题**: 路径错误
```bash
# 解决：批量替换
sed -i '' 's|旧路径|新路径|g' ~/.claude/settings.json
```

## 📊 迁移成功标准

当你看到以下所有现象时，说明迁移成功：

1. **基础功能**
   - ✅ Claude Code 启动无错误
   - ✅ 界面语言为中文
   - ✅ Spinner 显示自定义动词

2. **子 Agent**
   - ✅ 代码任务自动委托
   - ✅ 使用本地模型
   - ✅ 返回精简结果

3. **性能**
   - ✅ Token 消耗降低 70%+
   - ✅ 响应速度正常
   - ✅ 系统资源使用合理

4. **配置**
   - ✅ 所有配置文件正确
   - ✅ Ollama 正常运行
   - ✅ MCP 服务器连接成功

## 🎯 迁移后优化

### 性能调优

- [ ] **调整模型并发数**
  ```bash
  # 根据内存调整
  export OLLAMA_MAX_LOADED_MODELS=1
  ```

- [ ] **启用 GPU 加速**（如果有）
  ```bash
  export OLLAMA_NUM_GPU=1
  ```

- [ ] **清理缓存**
  ```bash
  claude --clear-cache
  ```

### 功能扩展

- [ ] **添加更多模型**
  ```bash
  ollama pull gemma4:31b
  ollama pull qwen3:32b
  ```

- [ ] **添加自定义 skills**
  ```bash
  vim ~/.claude/skills/my-skill.md
  ```

- [ ] **配置更多 MCP 服务器**
  ```bash
  vim ~/.claude/.mcp.json
  ```

## 📞 获取帮助

如果迁移遇到问题：

1. **查看日志**
   ```bash
   tail -f ~/.claude/logs/claude-code.log
   ```

2. **验证配置**
   ```bash
   jq empty ~/.claude/settings.json
   ```

3. **测试连接**
   ```bash
   curl http://localhost:11434/api/tags
   ```

4. **查看文档**
   - [安装指南](INSTALL_GUIDE.md)
   - [配置摘要](CONFIG_SUMMARY.md)
   - [完整文档](README.md)

## ✅ 完成确认

迁移完成后，确认以下所有项：

- [ ] 旧电脑信息已收集
- [ ] 新电脑环境已配置
- [ ] Ollama 已安装并运行
- [ ] Claude Code 已安装
- [ ] 配置文件已恢复
- [ ] 敏感信息已更新
- [ ] 所有验证通过
- [ ] 基础功能正常
- [ ] 子 Agent 正常
- [ ] 性能符合预期

**恭喜！迁移成功！** 🎉

现在你可以享受完全配置好的 Claude Code 环境了！
