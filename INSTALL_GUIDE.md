# 完整安装指南 - 新电脑配置 Claude Code

## 📋 前置准备

### 系统要求
- **操作系统**: macOS / Linux
- **内存**: 至少 16GB（推荐 32GB，用于运行本地模型）
- **磁盘**: 至少 50GB 可用空间（Ollama 模型较大）
- **网络**: 初次需要下载模型和依赖

### 检查系统
```bash
# 检查 macOS 版本
sw_vers

# 检查内存
system_profiler SPHardwareDataType | grep Memory

# 检查磁盘空间
df -h
```

## 🚀 完整安装流程

### 步骤 1: 安装 Homebrew（如果没有）

```bash
# 安装 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 添加到 PATH（Intel Mac）
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# 验证安装
brew --version
```

### 步骤 2: 安装 Ollama

```bash
# 使用 Homebrew 安装 Ollama
brew install ollama

# 启动 Ollama 服务
ollama serve

# 新开一个终端窗口，拉取模型
ollama pull qwen2.5-coder:32b

# 验证模型已安装
ollama list

# 测试模型运行
ollama run qwen2.5-coder:32b "你好"
```

**预期输出**：
```
NAME                    ID              SIZE      MODIFIED
qwen2.5-coder:32b       b92d6a0bd478    19GB      2026-05-09
```

### 步骤 3: 安装 Claude Code

```bash
# 使用 Homebrew 安装
brew install claude-code

# 验证安装
claude --version

# 登录（如果需要）
claude login
```

### 步骤 4: 克隆配置仓库

```bash
# 克隆配置
git clone https://github.com/leoredrum/claude-config-backup.git
cd claude-config-backup

# 查看仓库内容
ls -la
```

### 步骤 5: 运行恢复脚本

```bash
# 运行恢复脚本
./restore.sh

# 预期输出：
# 🚀 开始恢复 Claude Code 配置...
# 📦 备份现有配置...
# 📁 创建目录结构...
# 📋 复制配置文件...
# ✓ MCP 配置已恢复
# ✓ 本地配置已恢复
# ✓ Hooks 脚本已恢复
```

### 步骤 6: 配置敏感信息

```bash
# 编辑主配置文件
vim ~/.claude/settings.json
```

**必须修改的内容**：

1. **API Token**（从旧电脑获取）：
   ```json
   {
     "env": {
       "ANTHROPIC_AUTH_TOKEN": "366ed8d1857f4ab39ea028151a90107e.UPSwH2oBgC0Y3UNA",
       "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic"
     }
   }
   ```

   **获取 Token 的方法**（在旧电脑上）：
   ```bash
   cat ~/.claude/settings.json | grep AUTH_TOKEN
   ```

2. **用户路径**（根据新电脑修改）：
   ```json
   {
     "hooks": {
       "Notification": [{
         "hooks": [{
           "command": "/Users/新用户名/.claude/hooks/notify.sh"
         }]
       }]
     }
   }
   ```

   **获取当前用户名**：
   ```bash
   whoami
   # 输出: leo (或你的用户名)
   ```

3. **npm 路径**（重新安装插件后自动更新）：
   ```bash
   # 这个路径会在首次运行 Claude Code 时自动更新
   # 或者手动查找：
   find ~/.npm/_npx -name "zai-coding-plugins" 2>/dev/null
   ```

### 步骤 7: 验证配置

```bash
# 验证 JSON 语法
jq empty ~/.claude/settings.json
# 预期输出:（无错误）

jq empty ~/.claude/.mcp.json
# 预期输出:（无错误）

# 验证 Ollama 连接
curl http://localhost:11434/api/tags | jq .
# 预期输出: 包含 qwen2.5-coder:32b 的模型列表

# 验证 hooks 脚本可执行
ls -l ~/.claude/hooks/notify.sh
# 预期输出: -rwxr-xr-x (可执行权限)
```

### 步骤 8: 确保 Ollama 运行

```bash
# 检查 Ollama 是否运行
ps aux | grep ollama

# 如果没有运行，启动它
ollama serve &

# 或者使用 brew services（开机自启）
brew services start ollama

# 测试 Ollama API
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5-coder:32b",
  "prompt": "2+2=",
  "stream": false
}' | jq -r '.response'
```

**预期输出**: `4`（或正确的答案）

### 步骤 9: 启动 Claude Code

```bash
# 启动 Claude Code
claude

# 或者在后台运行
claude &

# 查看日志（如果有问题）
tail -f ~/.claude/logs/claude-code.log
```

### 步骤 10: 测试配置

在 Claude Code 中测试：

```bash
# 测试 1: 简单对话
> 你好

# 测试 2: 代码任务（应该自动使用子 Agent）
> 用 Python 写一个计算斐波那契数列的函数

# 测试 3: 文件操作
> 创建一个测试文件 test.txt 并写入 "Hello World"

# 测试 4: 本地模型
> 用 qwen2.5-coder:32b 模型解释一下这段代码
```

**预期行为**：
- ✅ 所有任务自动委托给子 Agent
- ✅ 使用本地模型执行
- ✅ 返回精简结果
- ✅ Spinner 显示中文动词

## 🔧 故障排查

### 问题 1: Ollama 连接失败

**症状**: `curl: (7) Failed to connect to localhost port 11434`

**解决**:
```bash
# 重启 Ollama
killall ollama
ollama serve &

# 检查端口
lsof -i :11434

# 如果端口被占用，更换端口
export OLLAMA_HOST=127.0.0.1:11435
ollama serve &
```

### 问题 2: 模型未找到

**症状**: `model 'qwen2.5-coder:32b' not found`

**解决**:
```bash
# 查看已安装的模型
ollama list

# 重新拉取模型
ollama pull qwen2.5-coder:32b

# 如果网络问题，使用镜像
export OLLAMA_HOST=127.0.0.1:11434
ollama pull qwen2.5-coder:32b
```

### 问题 3: JSON 语法错误

**症状**: `parse error: Expected ':' before EOF`

**解决**:
```bash
# 验证 JSON
jq empty ~/.claude/settings.json

# 如果有错误，查看具体位置
jq . ~/.claude/settings.json | less

# 常见错误：
# - 缺少逗号
# - 多余的逗号
# - 括号不匹配
```

### 问题 4: 权限问题

**症状**: `Permission denied (publickey)`

**解决**:
```bash
# 检查文件权限
ls -la ~/.claude/

# 修复权限
chmod 755 ~/.claude/hooks/notify.sh
chmod 644 ~/.claude/settings.json
chmod 644 ~/.claude/.mcp.json
```

### 问题 5: MCP 服务器未启动

**症状**: `MCP server 'ollama' failed to start`

**解决**:
```bash
# 手动测试 MCP 服务器
npx -y ollama-mcp

# 查看 MCP 日志
cat ~/.claude/logs/mcp-ollama.log

# 重新安装 MCP 包
npm install -g ollama-mcp
```

### 问题 6: 子 Agent 不工作

**症状**: 任务直接由主 Agent 执行，没有委托

**解决**:
```bash
# 检查 workflow orchestrator 插件
cat ~/.claude/settings.json | grep workflow-orchestrator

# 确认输出应该包含：
# "workflow-orchestrator@barkain-plugins": true

# 如果没有，手动添加
vim ~/.claude/settings.json
```

### 问题 7: 内存不足

**症状**: 系统变慢，模型加载失败

**解决**:
```bash
# 检查内存使用
top -o mem

# 使用更小的模型
ollama pull qwen2.5-coder:7b

# 修改配置使用小模型
vim ~/.claude/settings.json
# 将 "OLLAMA_MODEL": "qwen2.5-coder:32b"
# 改为 "OLLAMA_MODEL": "qwen2.5-coder:7b"
```

## 📊 性能优化

### 优化 Ollama 性能

```bash
# 设置 Ollama 内存限制（根据你的系统）
export OLLAMA_NUM_GPU=1  # 使用 GPU 加速（如果有）
export OLLAMA_MAX_LOADED_MODELS=1  # 限制同时加载的模型数

# 使用量化模型（更快但精度略低）
ollama pull qwen2.5-coder:32b-q4_0  # Q4 量化版本

# 监控 Ollama 性能
ollama ps
```

### 优化 Claude Code 性能

```bash
# 清理缓存
claude --clear-cache

# 调整上下文窗口
export CLAUDE_CONTEXT_WINDOW=200000

# 禁用不必要的功能
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
```

## 🔄 更新配置

### 更新 Ollama 模型

```bash
# 更新到最新版本
ollama pull qwen2.5-coder:32b

# 查看可用更新
ollama list
```

### 更新 Claude Code

```bash
# 使用 Homebrew 更新
brew upgrade claude-code

# 验证版本
claude --version
```

### 更新配置文件

```bash
# 拉取最新配置
cd ~/claude-config-backup  # 或你克隆的目录
git pull

# 重新应用配置
./restore.sh
```

## 📝 配置验证清单

安装完成后，确认以下所有项都通过：

- [ ] Homebrew 已安装 (`brew --version`)
- [ ] Ollama 已安装 (`ollama --version`)
- [ ] qwen2.5-coder:32b 模型已下载 (`ollama list`)
- [ ] Claude Code 已安装 (`claude --version`)
- [ ] 配置文件已恢复 (`ls ~/.claude/settings.json`)
- [ ] JSON 语法正确 (`jq empty ~/.claude/settings.json`)
- [ ] Ollama 服务运行中 (`curl http://localhost:11434/api/tags`)
- [ ] API Token 已配置
- [ ] 用户路径已更新
- [ ] Hooks 脚本可执行 (`ls -l ~/.claude/hooks/notify.sh`)
- [ ] Claude Code 可以正常启动
- [ ] 简单对话测试通过
- [ ] 代码任务测试通过（子 Agent）
- [ ] 本地模型测试通过

## 🎯 下一步

配置完成后，你可以：

1. **阅读配置详情**: [CONFIG_SUMMARY.md](CONFIG_SUMMARY.md)
2. **查看快速指南**: [QUICKSTART.md](QUICKSTART.md)
3. **了解完整文档**: [README.md](README.md)
4. **自定义配置**: 根据需要调整 `~/.claude/settings.json`

## 💡 高级配置

### 添加更多 Ollama 模型

```bash
# 拉取其他模型
ollama pull gemma4:31b
ollama pull qwen3:32b

# 在配置中切换模型
vim ~/.claude/settings.json
# 修改 "OLLAMA_MODEL" 的值
```

### 配置多个 MCP 服务器

```bash
# 编辑 MCP 配置
vim ~/.claude/.mcp.json

# 添加更多服务器（示例：文件系统 MCP）
{
  "mcpServers": {
    "ollama": { ... },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/allowed/path"]
    }
  }
}
```

### 自定义 Skills

```bash
# 创建自定义 skill
vim ~/.claude/skills/my-custom-skill.md

# 内容示例：
---
name: my-custom-skill
description: 我的自定义技能
---

## 使用场景
当你需要 X 时，使用此技能。

## 具体步骤
1. 第一步
2. 第二步
3. 第三步
```

## 🆘 获取帮助

如果遇到问题：

1. **查看日志**: `~/.claude/logs/`
2. **验证配置**: `jq empty ~/.claude/settings.json`
3. **测试连接**: `curl http://localhost:11434/api/tags`
4. **重启服务**: `killall ollama && ollama serve`
5. **查看文档**: [README.md](README.md)

## ✅ 完成确认

当你看到以下现象时，说明配置成功：

- ✅ Claude Code 正常启动
- ✅ Spinner 显示中文动词
- ✅ 代码任务自动委托给子 Agent
- ✅ 使用本地模型（无 API 调用）
- ✅ 返回精简结果
- ✅ Token 消耗大幅降低

**恭喜！你现在拥有一个完全配置好的 Claude Code 环境！** 🎉
