# 更新日志 (Changelog)

本文档记录 Claude Code 配置的所有重要变更。

## [Unreleased]

### 计划中
- 添加更多 Ollama 模型配置示例
- 添加性能监控脚本
- 添加自动更新脚本

---

## [1.0.0] - 2026-05-10

### 新增

#### 核心配置
- ✨ **子 Agent 自动委托** - Workflow Orchestrator 集成
- ✨ **本地模型集成** - Ollama qwen2.5-coder:32b
- ✨ **MCP 服务器** - ollama-mcp 配置
- ✨ **Token 优化** - 节省 70-90% API 成本

#### 界面定制
- 🎨 **中文 Spinner** - 200+ 自定义动词
- 💬 **中文提示** - 30+ 自定义提示语
- 🌙 **暗色主题** - Dark theme

#### 自动化
- 🔄 **自动 Hooks** - Notification 和 Stop hooks
- 🤖 **自动编排** - 任务自动分解和并行处理
- 🔧 **自动配置** - npm 路径自动更新

#### 文档
- 📚 **完整文档** - README.md
- 🚀 **快速指南** - QUICKSTART.md
- 📋 **安装指南** - INSTALL_GUIDE.md
- ✅ **迁移清单** - MIGRATION_CHECKLIST.md
- ❓ **常见问题** - FAQ.md
- 📊 **配置摘要** - CONFIG_SUMMARY.md
- 🛠️ **恢复脚本** - restore.sh

### 配置详情

#### 环境变量
```json
{
  "OLLAMA_MODEL": "qwen2.5-coder:32b",
  "OLLAMA_HOST": "http://localhost:11434",
  "API_TIMEOUT_MS": "3000000",
  "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
}
```

#### 权限配置
- 允许：Bash, Read, Edit, Write, Glob, Grep, Agent, WebFetch, WebSearch
- 拒绝：osascript, sudo, security, pkexec
- 默认模式：bypassPermissions

#### 插件
- workflow-orchestrator@barkain-plugins
- glm-plan-usage@zai-coding-plugins

#### MCP 服务器
- ollama (npx -y ollama-mcp)

### 工作流程

```
用户指令
    ↓
主 Agent 识别任务
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

### 性能指标

- **Token 节省**: 70-90%
- **主 Agent 使用**: ~10%
- **子 Agent 使用**: ~0% (本地模型)
- **响应速度**: 本地模型无延迟

### 系统要求

- **操作系统**: macOS 12+ / Linux
- **内存**: 16GB+ (推荐 32GB)
- **磁盘**: 50GB+ (Ollama 模型)
- **网络**: 初次下载需要

### 依赖

- Homebrew
- Ollama
- Claude Code
- jq (JSON 处理)
- Node.js & npm (MCP 服务器)

### 已知问题

- ~~Ollama 首次启动较慢~~ (正常行为)
- ~~大模型占用内存较多~~ (可用小模型替代)
- ~~某些简单任务可能不需要子 Agent~~ (设计如此)

### 兼容性

- ✅ Claude Code 最新版
- ✅ Ollama 最新稳定版
- ✅ macOS 12+ (Monterey 及以上)
- ✅ Linux (Ubuntu 20.04+, Debian 11+)
- ⚠️ Windows (WSL2 需额外配置)

---

## 版本说明

### 语义化版本

- **主版本号** (MAJOR): 不兼容的 API 变更
- **次版本号** (MINOR): 向下兼容的功能新增
- **修订号** (PATCH): 向下兼容的问题修正

### 更新类型

- **新增** (Added): 新功能
- **变更** (Changed): 现有功能的变更
- **弃用** (Deprecated): 即将移除的功能
- **移除** (Removed): 已移除的功能
- **修复** (Fixed): 问题修复
- **安全** (Security): 安全相关的修复

---

## 贡献指南

如果你想贡献配置或文档：

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 提交规范

遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

- `feat:` 新功能
- `fix:` 问题修复
- `docs:` 文档更新
- `style:` 代码格式
- `refactor:` 代码重构
- `perf:` 性能优化
- `test:` 测试相关
- `chore:` 构建/工具相关

---

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

---

## 致谢

- [Claude Code](https://claude.ai/code) - Anthropic
- [Ollama](https://ollama.ai) - 本地 LLM 运行时
- [Workflow Orchestrator](https://github.com/barkain/claude-code-workflow-orchestration) - 任务编排
- [Ollama MCP Server](https://github.com/rawveg/ollama-mcp) - MCP 集成

---

**最后更新**: 2026-05-10
