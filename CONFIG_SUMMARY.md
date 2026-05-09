# 配置摘要

## 🎯 核心配置

### 本地模型
- **模型**: qwen2.5-coder:32b (Ollama)
- **API**: http://localhost:11434
- **成本**: 免费（本地运行）

### 子 Agent 设置
- **自动委托**: ✅ 启用
- **编排器**: Workflow Orchestrator
- **Token 节省**: ~70-90%

### 界面
- **语言**: 中文
- **主题**: Dark
- **Spinner**: 自定义中文动词

## 📦 已安装插件

1. **workflow-orchestrator@barkain-plugins**
   - 任务自动分解
   - 子 Agent 并行执行
   - 依赖管理

2. **glm-plan-usage@zai-coding-plugins**
   - GLM 计划用量查询

## 🔧 权限配置

### 允许的操作
- Bash, Read, Edit, Write
- Glob, Grep, Agent
- WebFetch, WebSearch

### 拒绝的操作
- `osascript:*`
- `sudo:*`
- `security:*`
- `pkexec:*`

### 默认模式
- `bypassPermissions` - 自动允许所有工具

## 🔌 MCP 服务器

1. **ollama** - 本地模型集成
   - 命令: `npx -y ollama-mcp`
   - 环境变量: `OLLAMA_HOST=http://localhost:11434`

## 📝 Hook 配置

1. **Notification Hook**
   - 脚本: `~/.claude/hooks/notify.sh`
   - 触发: 所有通知

2. **Stop Hook**
   - 脚本: `~/.claude/hooks/notify.sh`
   - 触发: Claude 停止时
   - 模式: 异步

## 🎨 自定义 Spinner

### 动词 (200+ 个中文动词)
- 搞定中、行动中、架构中、烘焙中...
- 模式: replace (完全替换默认)

### 提示 (30+ 条中文提示)
- 从小功能开始、先用 Plan 模式...
- 模式: excludeDefault (只显示自定义)

## 🔄 工作流程

```
用户指令
    ↓
主 Agent 识别任务类型
    ↓
自动委托给 Workflow Orchestrator
    ↓
分解为子任务
    ↓
子 Agent (本地 Ollama) 执行
    ↓
返回精简结果
    ↓
主 Agent 整合并回复
```

## 📊 性能优化

### Token 使用
- **主 Agent**: ~10% (规划 + 协调)
- **子 Agent**: 0% (本地模型)
- **总计**: 节省 70-90%

### 速度优化
- 并行子任务
- 本地模型无延迟
- 精简上下文传输

## 🛠️ 故障排查

### Ollama 连接失败
```bash
# 检查服务
curl http://localhost:11434/api/tags

# 重启服务
killall ollama && ollama serve
```

### MCP 服务器未启动
```bash
# 测试 MCP
npx -y ollama-mcp

# 查看日志
~/.claude/logs/mcp-ollama.log
```

### 配置语法错误
```bash
# 验证 JSON
jq empty ~/.claude/settings.json
jq empty ~/.claude/.mcp.json
```

## 📅 配置版本

- **创建日期**: 2026-05-10
- **Claude Code 版本**: 当前最新
- **Ollama 版本**: 最新稳定版
- **测试状态**: ✅ 已验证

## 🚀 下次更新

考虑添加：
- [ ] 更多 Ollama 模型配置
- [ ] 自定义 Skills
- [ ] 更多 MCP 服务器
- [ ] 性能监控脚本
