# cc-haha 混合Agent配置方案

## 概述

本配置为 cc-haha (Claude Code 桌面版) 提供智谱 GLM + 本地 Ollama 的混合Agent方案：

- **主 Agent**: 智谱 GLM-4-Plus/Flash - 负责任务规划、协调和决策
- **子 Agent**: 本地 Ollama Qwen2.5-Coder:32b - 负责代码编写、文件操作等具体任务

**优势**:
- 节省 70-90% API 成本（子Agent使用本地模型）
- 保持高质量的主Agent决策能力
- 完全本地化，数据隐私有保障
- 无需外部API调用子任务

## 系统要求

### 必需组件

1. **cc-haha 桌面版**
   ```bash
   # 克隆仓库
   git clone https://github.com/NanmiCoder/cc-haha.git
   cd cc-haha

   # 安装依赖
   npm install

   # 启动桌面版
   npm run electron
   ```

2. **Ollama**
   ```bash
   # macOS/Linux
   curl -fsSL https://ollama.com/install.sh | sh

   # 拉取模型
   ollama pull qwen2.5-coder:32b

   # 启动服务
   ollama serve
   ```

3. **Python 3.8+**
   ```bash
   python3 --version
   ```

4. **智谱 AI API Key**
   - 访问 https://open.bigmodel.cn/
   - 注册并获取 API Key

### 硬件建议

- **CPU**: 4核及以上
- **内存**: 16GB 及以上（Qwen2.5-Coder:32b 需要约 16GB）
- **硬盘**: 20GB 可用空间

## 快速开始

### 1. 准备配置文件

```bash
# 进入配置目录
cd ~/Desktop/claude-config-backup

# 复制环境变量模板
cp cc-haha-env-template .env

# 编辑 .env 文件，填入你的 ZHIPUAI_API_KEY
nano .env  # 或使用其他编辑器
```

### 2. 启动服务

```bash
# 运行启动脚本
./start-cc-haha.sh
```

启动脚本会自动：
- ✓ 检查所有依赖（Python、Node.js、Ollama）
- ✓ 安装/检查 LiteLLM
- ✓ 启动 LiteLLM 代理（端口 4000）
- ✓ 显示启动状态和日志位置

### 3. 配置 cc-haha

在 cc-haha 桌面版中：

1. **打开设置**
   - 点击齿轮图标 → Settings

2. **配置 API**
   - API Base URL: `http://localhost:4000`
   - API Key: `sk-litellm-proxy`（任意值即可）
   - Model: `glm-4-plus`（主Agent）或 `glm-4-flash`（快速版）

3. **保存并重启 cc-haha**

## 配置文件说明

### cc-haha-litellm-config.yaml

LiteLLM 代理配置文件，定义了模型映射和代理设置。

**模型列表**:
- `glm-4-plus`: 智谱最强模型，主Agent使用
- `glm-4-flash`: 智谱快速模型，适合简单任务
- `qwen2.5-coder-32b`: 本地Ollama模型，子Agent使用
- `qwen2.5-coder-7b`: 本地备用小模型，资源受限时使用

**关键配置**:
```yaml
litellm_settings:
  drop_params: true        # 丢弃Anthropic专有参数
  max_budget: 100.0        # 最大预算
  num_retries: 3           # 重试次数
  request_timeout: 300     # 请求超时（秒）
```

### .env

环境变量配置文件。

**必需变量**:
- `ZHIPUAI_API_KEY`: 智谱AI的API密钥（必填）
- `ANTHROPIC_BASE_URL`: LiteLLM代理地址（默认 http://localhost:4000）
- `OLLAMA_HOST`: Ollama服务地址（默认 http://localhost:11434）

## 工作原理

```
┌─────────────┐
│  cc-haha    │
│  桌面版      │
└──────┬──────┘
       │
       ↓ (Anthropic API)
┌─────────────┐
│  LiteLLM    │
│  代理        │
│  :4000      │
└──────┬──────┘
       │
       ├────────→ 智谱 GLM-4 (主Agent)
       │           - 任务规划
       │           - 协调决策
       │           - API调用
       │
       └────────→ Ollama (子Agent)
                   - 代码编写
                   - 文件操作
                   - 本地执行
```

### 数据流

1. **用户请求** → cc-haha 桌面版
2. **cc-haha** → 调用 Anthropic API（指向 LiteLLM 代理）
3. **LiteLLM** → 根据模型名称路由：
   - `glm-4-*` → 智谱 AI API
   - `qwen2.5-coder-*` → 本地 Ollama
4. **模型响应** → LiteLLM → cc-haha → 用户

## 多Agent系统配置

cc-haha 支持配置多个Agent，实现主从架构：

### 主Agent配置（智谱GLM）
- **用途**: 任务规划、代码审查、架构设计
- **模型**: `glm-4-plus`
- **优势**: 高质量决策、强大的理解能力

### 子Agent配置（Ollama）
- **用途**: 代码编写、文件搜索、文本处理
- **模型**: `qwen2.5-coder-32b`
- **优势**: 本地运行、零API成本、快速响应

### 自动分配规则

cc-haha 会根据任务类型自动选择Agent：

| 任务类型 | 使用Agent | 原因 |
|---------|----------|------|
| 系统架构设计 | 主Agent (智谱) | 需要全局视角 |
| 代码编写 | 子Agent (Ollama) | 高频操作，节省成本 |
| 代码审查 | 主Agent (智谱) | 需要深度分析 |
| 文件搜索 | 子Agent (Ollama) | 简单操作 |
| 重构建议 | 主Agent (智谱) | 需要理解上下文 |
| Bug修复 | 子Agent (Ollama) | 具体实现 |

## 验证配置

### 1. 检查 LiteLLM 代理

```bash
# 健康检查
curl http://localhost:4000/health

# 应该返回: {"status": "ok"}
```

### 2. 测试智谱连接

```bash
curl http://localhost:4000/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: sk-litellm-proxy" \
  -d '{
    "model": "glm-4-plus",
    "max_tokens": 100,
    "messages": [{"role": "user", "content": "你好"}]
  }'
```

### 3. 测试 Ollama 连接

```bash
curl http://localhost:4000/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: sk-litellm-proxy" \
  -d '{
    "model": "qwen2.5-coder-32b",
    "max_tokens": 100,
    "messages": [{"role": "user", "content": "写一个Python函数"}]
  }'
```

### 4. cc-haha 测试

在 cc-haha 桌面版中输入：

```
请帮我创建一个Python文件，包含一个计算斐波那契数列的函数
```

观察cc-haha是否：
- ✓ 正常调用主Agent
- ✓ 委托子Agent执行代码编写
- ✓ 返回完整结果

## 故障排除

### LiteLLM 启动失败

**问题**: 端口 4000 被占用
```bash
# 查找占用进程
lsof -i :4000

# 关闭进程
kill -9 <PID>
```

**问题**: 配置文件错误
```bash
# 验证 YAML 语法
python3 -c "import yaml; yaml.safe_load(open('cc-haha-litellm-config.yaml'))"
```

### Ollama 连接失败

**问题**: 模型未安装
```bash
ollama pull qwen2.5-coder:32b
```

**问题**: 服务未启动
```bash
ollama serve
```

### 智谱 API 调用失败

**问题**: API Key 无效
- 检查 `.env` 文件中的 `ZHIPUAI_API_KEY`
- 确认 API Key 有效且有额度

**问题**: 网络问题
```bash
# 测试连接
curl https://open.bigmodel.cn/api/paas/v4/chat/completions
```

### cc-haha 无法连接

**问题**: API Base URL 配置错误
- 确认设置为 `http://localhost:4000`
- 不要包含 `/v1` 后缀

**问题**: 代理未启动
```bash
# 查看LiteLLM日志
tail -f /tmp/litellm.log
```

## 停止服务

```bash
# 停止 LiteLLM
pkill -f 'litellm --config'

# 或者使用启动脚本中的 PID
kill $LITELLM_PID

# 确认已停止
lsof -i :4000  # 应该没有输出
```

## 性能优化

### 子Agent模型选择

根据硬件配置选择合适的子Agent模型：

| 内存 | 推荐模型 | 参数量 | 用途 |
|------|---------|--------|------|
| 8GB  | qwen2.5-coder:7b | 7B | 资源受限环境 |
| 16GB | qwen2.5-coder:14b | 14B | 平衡性能 |
| 32GB+ | qwen2.5-coder:32b | 32B | 最佳性能 |

### LiteLLM 性能调优

编辑 `cc-haha-litellm-config.yaml`:

```yaml
litellm_settings:
  # 并发请求数
  max_parallel_requests: 10

  # 缓存配置
  cache: true
  cache_type: simple

  # 连接池
  max_connections: 100
```

### 主Agent选择

根据任务复杂度选择主Agent：

- **glm-4-flash**: 简单任务、快速响应（成本更低）
- **glm-4-plus**: 复杂任务、深度分析（质量更高）

## 成本估算

### Token消耗对比

假设每天处理 100 个任务：

| 方案 | 主Agent | 子Agent | 日消耗 | 月成本 |
|------|---------|---------|--------|--------|
| 纯智谱 | 100% | - | 200K tokens | ¥180 |
| 混合方案 | 20% | 80% | 40K tokens + 本地 | ¥36 |

**节省**: 80% API成本

### 具体计算

智谱 GLM-4 定价（2025年）：
- 输入: ¥0.50/百万tokens
- 输出: ¥2.00/百万tokens

假设平均任务：
- 主Agent: 2000 tokens（规划）
- 子Agent: 8000 tokens（执行）× 本地免费

日成本 = (2000 × ¥0.5 + 2000 × ¥2.0) / 1000000 × 100 = ¥0.50
月成本 ≈ ¥15

## 进阶配置

### 自定义模型路由

编辑 `cc-haha-litellm-config.yaml`，添加模型别名：

```yaml
model_list:
  - model_name: claude-sonnet-4-20250514
    litellm_params:
      model: zhipuai/glm-4-plus
      api_key: os.environ/ZHIPUAI_API_KEY
```

这样 cc-haha 调用 `claude-sonnet-4-20250514` 时会实际使用智谱 GLM-4-Plus。

### 添加备用模型

```yaml
model_list:
  - model_name: deepseek-chat
    litellm_params:
      model: deepseek/deepseek-chat
      api_key: os.environ/DEEPSEEK_API_KEY
```

### 负载均衡

```yaml
litellm_settings:
  # 在多个模型间负载均衡
  fallbacks: [{"glm-4-plus": ["glm-4-flash", "qwen2.5-coder-32b"]}]
```

## 安全建议

1. **保护 API Key**
   - 不要将 `.env` 文件提交到 Git
   - 使用环境变量或密钥管理工具

2. **本地网络**
   - LiteLLM 代理默认监听 `localhost`，仅本机访问
   - 如需远程访问，配置防火墙规则

3. **Ollama 安全**
   - 仅在可信网络中暴露 Ollama 端口
   - 定期更新 Ollama 版本

## 相关链接

- **cc-haha**: https://github.com/NanmiCoder/cc-haha
- **LiteLLM**: https://docs.litellm.ai/
- **Ollama**: https://ollama.com/
- **智谱AI**: https://open.bigmodel.cn/
- **Qwen2.5-Coder**: https://ollama.com/library/qwen2.5-coder

## 常见问题

**Q: 为什么需要 LiteLLM？**
A: cc-haha 使用 Anthropic API 协议，而 Ollama 使用 OpenAI 协议。LiteLLM 充当转换代理。

**Q: 子Agent可以完全离线吗？**
A: 是的，Ollama 完全本地运行，无需互联网连接。

**Q: 可以替换为其他模型吗？**
A: 可以，只需在 `cc-haha-litellm-config.yaml` 中添加模型配置。

**Q: 如何监控Token使用？**
A: 查看 LiteLLM 日志：`tail -f /tmp/litellm.log`

**Q: 支持多用户吗？**
A: 本配置为单用户设计。多用户需要部署独立的 LiteLLM 服务器。

## 更新日志

- **2025-05-10**: 初始版本
  - 支持智谱 GLM-4-Plus/Flash
  - 支持本地 Ollama Qwen2.5-Coder:32b
  - 自动化启动脚本
  - 完整文档

---

**配置完成！** 🎉

如有问题，请查看 [故障排除](#故障排除) 部分或提交 Issue。
