#!/bin/bash
# cc-haha 启动脚本 - 智谱主Agent + Ollama子Agent混合方案

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/cc-haha-litellm-config.yaml"
ENV_FILE="$SCRIPT_DIR/.env"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "======================================"
echo "  cc-haha 混合Agent启动脚本"
echo "  主Agent: 智谱 GLM-4-Plus"
echo "  子Agent: 本地 Ollama Qwen2.5-Coder:32b"
echo "======================================"
echo ""

# 1. 检查依赖
echo -e "${YELLOW}[1/6] 检查依赖...${NC}"

# 检查 Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ Python3 未安装${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Python3 已安装: $(python3 --version)${NC}"

# 检查 Node.js (cc-haha 需要)
if ! command -v node &> /dev/null; then
    echo -e "${RED}✗ Node.js 未安装${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Node.js 已安装: $(node --version)${NC}"

# 检查 Ollama
if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo -e "${RED}✗ Ollama 服务未运行${NC}"
    echo "请先启动 Ollama: ollama serve"
    exit 1
fi
echo -e "${GREEN}✓ Ollama 服务运行中${NC}"

# 检查 qwen2.5-coder:32b 模型
if ! ollama list | grep -q "qwen2.5-coder:32b"; then
    echo -e "${YELLOW}⚠ qwen2.5-coder:32b 模型未安装${NC}"
    echo "正在安装... (这需要一些时间)"
    ollama pull qwen2.5-coder:32b
fi
echo -e "${GREEN}✓ Qwen2.5-Coder:32b 模型已安装${NC}"

echo ""

# 2. 检查配置文件
echo -e "${YELLOW}[2/6] 检查配置文件...${NC}"

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}✗ LiteLLM 配置文件不存在: $CONFIG_FILE${NC}"
    exit 1
fi
echo -e "${GREEN}✓ LiteLLM 配置文件存在${NC}"

if [ ! -f "$ENV_FILE" ]; then
    echo -e "${YELLOW}⚠ .env 文件不存在，从模板创建...${NC}"
    cp "$SCRIPT_DIR/cc-haha-env-template" "$ENV_FILE"
    echo -e "${YELLOW}请编辑 $ENV_FILE 并填入你的 ZHIPUAI_API_KEY${NC}"
    echo "获取 API Key: https://open.bigmodel.cn/"
    exit 1
fi
echo -e "${GREEN}✓ 环境变量文件存在${NC}"

echo ""

# 3. 加载环境变量
echo -e "${YELLOW}[3/6] 加载环境变量...${NC}"
export $(grep -v '^#' "$ENV_FILE" | xargs)
echo -e "${GREEN}✓ 环境变量已加载${NC}"
echo ""

# 4. 安装/检查 LiteLLM
echo -e "${YELLOW}[4/6] 检查 LiteLLM...${NC}"

if ! command -v litellm &> /dev/null; then
    echo "安装 LiteLLM..."
    pip3 install litellm
else
    echo -e "${GREEN}✓ LiteLLM 已安装: $(litellm --version)${NC}"
fi

echo ""

# 5. 启动 LiteLLM 代理
echo -e "${YELLOW}[5/6] 启动 LiteLLM 代理...${NC}"
echo "配置文件: $CONFIG_FILE"
echo "监听地址: http://localhost:4000"
echo ""

# 检查端口 4000 是否已被占用
if lsof -Pi :4000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠ 端口 4000 已被占用${NC}"
    echo "尝试关闭现有 LiteLLM 进程..."
    pkill -f "litellm --config" || true
    sleep 2
fi

# 后台启动 LiteLLM
nohup litellm --config "$CONFIG_FILE" --port 4000 > /tmp/litellm.log 2>&1 &
LITELLM_PID=$!
echo "LiteLLM 进程 PID: $LITELLM_PID"

# 等待 LiteLLM 启动
echo "等待 LiteLLM 代理启动..."
for i in {1..30}; do
    if curl -s http://localhost:4000/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ LiteLLM 代理启动成功${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}✗ LiteLLM 启动超时${NC}"
        echo "查看日志: tail -f /tmp/litellm.log"
        exit 1
    fi
    sleep 1
done

echo ""

# 6. 启动 cc-haha
echo -e "${YELLOW}[6/6] 启动 cc-haha...${NC}"
echo ""
echo -e "${GREEN}======================================"
echo "  所有服务已启动！"
echo "======================================"
echo ""
echo "LiteLLM 代理: http://localhost:4000"
echo "Ollama 服务: http://localhost:11434"
echo ""
echo "现在可以启动 cc-haha 桌面版了！"
echo ""
echo "停止服务:"
echo "  kill $LITELLM_PID"
echo "  或运行: pkill -f 'litellm --config'"
echo ""
echo "查看日志:"
echo "  tail -f /tmp/litellm.log"
echo ""
echo "======================================"
echo ""

# 保持脚本运行，等待 Ctrl+C
trap "echo ''; echo '正在停止服务...'; kill $LITELLM_PID 2>/dev/null; exit 0" INT TERM

wait $LITELLM_PID
