# Claude Code 配置备份

这是我的 Claude Code 完整配置，包含本地模型（Ollama）和子 Agent 的自动化设置。

## 📋 配置清单

### ✅ 已包含配置

- **settings.json 模板** - 主配置（需填入敏感信息）
- **.mcp.json** - Ollama MCP 服务器配置
- **settings.local.json** - 本地配置覆盖
- **hooks/notify.sh** - 通知脚本
- **自定义 spinner** - 中文动词和提示语
- **Workflow Orchestrator** - 子 Agent 自动编排
- **Ollama 集成** - 本地 qwen2.5-coder:32b 模型

### 🎯 核心特性

1. **自动子 Agent 委托** - 所有任务自动分配给子 Agent
2. **本地模型优先** - 使用 Ollama 节省 API 成本
3. **中文界面** - 完整的中文 spinner 和提示
4. **Workflow Orchestrator** - 任务自动分解和并行处理

## 🚀 新电脑恢复步骤

### 1. 克隆配置

```bash
git clone https://github.com/YOUR_USERNAME/claude-config-backup.git
cd claude-config-backup
```

### 2. 运行恢复脚本

```bash
./restore.sh
```

### 3. 配置敏感信息

编辑 `~/.claude/settings.json`，填入：

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "your_actual_token_here",
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic"
  }
}
```

### 4. 调整路径

根据新电脑的用户名和路径，修改：

- `/Users/YOUR_USERNAME/.claude/hooks/notify.sh` → 改为新用户名
- npm 路径 → 重新安装插件后自动更新

### 5. 安装依赖

```bash
# 确保 Ollama 已安装并运行
brew install ollama
ollama serve

# 拉取模型（如果还没有）
ollama pull qwen2.5-coder:32b
```

### 6. 重启 Claude Code

关闭并重新打开 Claude Code，配置即可生效。

## 📝 配置说明

### 环境变量

- `OLLAMA_MODEL=qwen2.5-coder:32b` - 默认使用的本地模型
- `OLLAMA_HOST=http://localhost:11434` - Ollama 服务地址

### 权限配置

- 允许所有常用工具（Read, Write, Edit, Bash 等）
- 拒绝危险操作（sudo, osascript 等）
- 默认模式：bypassPermissions

### 插件

- `workflow-orchestrator@barkain-plugins` - 任务编排
- `glm-plan-usage@zai-coding-plugins` - GLM 计划用量查询

### MCP 服务器

- `ollama` - 本地模型集成

## 🔧 手动配置（如果脚本失败）

### 1. 复制文件

```bash
mkdir -p ~/.claude/hooks
cp claude-settings-template.json ~/.claude/settings.json
cp .claude/.mcp.json ~/.claude/.mcp.json
cp .claude/settings.local.json ~/.claude/settings.local.json
cp .claude/hooks/notify.sh ~/.claude/hooks/notify.sh
chmod +x ~/.claude/hooks/notify.sh
```

### 2. 验证 JSON

```bash
jq empty ~/.claude/settings.json
jq empty ~/.claude/.mcp.json
```

### 3. 重启 Claude Code

## 🎨 自定义配置

### 修改默认模型

编辑 `~/.claude/settings.json`:

```json
{
  "env": {
    "OLLAMA_MODEL": "gemma4:31b"  // 改成你想要的模型
  }
}
```

### 添加自定义 Skills

在 `~/.claude/skills/` 目录添加 `.md` 文件即可。

### 修改 Spinner

编辑 `settings.json` 中的 `spinnerVerbs` 和 `spinnerTipsOverride`。

## 📊 Token 节省效果

使用这套配置后：

- **主 Agent** - 只负责规划和协调（~10% token）
- **子 Agent** - 使用本地模型执行（0 API 成本）
- **总节省** - 约 70-90% 的 API token

## ⚠️ 注意事项

1. **敏感信息** - `settings.json` 包含 API token，不要提交到公开仓库
2. **路径差异** - 新电脑的用户名可能不同，需要调整路径
3. **Ollama 模型** - 确保在新电脑上安装了相同的 Ollama 模型
4. **npm 插件** - 重新安装后路径会自动更新

## 🔄 更新配置

修改配置后：

```bash
# 提交更改
git add .
git commit -m "Update config"
git push
```

## 📚 相关资源

- [Ollama 官网](https://ollama.ai)
- [Claude Code 文档](https://claude.ai/code)
- [Workflow Orchestrator](https://github.com/barkain/claude-code-workflow-orchestration)
- [Ollama MCP Server](https://github.com/rawveg/ollama-mcp)

## 📅 更新历史

- 2026-05-10 - 初始配置备份
  - Ollama qwen2.5-coder:32b 集成
  - Workflow Orchestrator 配置
  - 中文界面配置
  - 子 Agent 自动委托
