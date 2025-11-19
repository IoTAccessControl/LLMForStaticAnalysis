import os
import json
import argparse
from pathlib import Path
from dotenv import load_dotenv

# =========================
# Step 1. 加载环境变量
# =========================
load_dotenv()

# =========================
# Step 2. 声明 system_prompt
# =========================
from system_prompt import system_prompt

# =========================
# Step 3. 获取根目录
# =========================
root_dir = Path(os.getcwd())

# =========================
# Step 4. 模型配置
# =========================
VALID_MODELS = ["qwen3-coder-plus", "glm-4.6"]

def get_llm_client(model_name):
    """根据模型名称创建并返回相应的 LLM 客户端。"""
    if model_name == "qwen3-coder-plus":
        from openai import OpenAI
        api_key = os.getenv("DASHSCOPE_API_KEY")
        if not api_key:
            raise EnvironmentError("[ERROR] Missing DASHSCOPE_API_KEY in .env")
        client = OpenAI(
            api_key=api_key,
            base_url="https://dashscope.aliyuncs.com/compatible-mode/v1"
        )
        return client
    elif model_name == "glm-4.6":
        from zai import ZhipuAiClient
        api_key = os.getenv("ZHIPU_API_KEY")
        if not api_key:
            raise EnvironmentError("[ERROR] Missing ZHIPU_API_KEY in .env")
        client = ZhipuAiClient(api_key=api_key)
        return client
    else:
        raise ValueError(f"[ERROR] Unsupported model: {model_name}")

# =========================
# Step 5. 工具函数
# =========================
def add_line_numbers(code_text: str) -> str:
    """为代码每一行添加行号"""
    return "\n".join(f"{i + 1}: {line}" for i, line in enumerate(code_text.splitlines()))

def read_code_with_line_numbers(file_path: Path) -> str:
    """读取代码文件并添加行号"""
    if not file_path.exists():
        print(f"[WARN] File not found: {file_path}")
        return ""
    content = file_path.read_text(encoding="utf-8")
    return add_line_numbers(content)

def read_question(file_path: Path, target_file: str) -> str:
    """读取 question.json 并返回与目标文件对应的问题"""
    if not file_path.exists():
        print(f"[WARN] {file_path} not found.")
        return ""
    data = json.loads(file_path.read_text(encoding="utf-8"))
    for item in data:
        if item.get("file_name") == target_file.name:
            return item.get("question", "")
    print(f"[WARN] No question found for {target_file.name}")
    return ""

def call_llm(model_name: str, client, system_prompt: str, user_prompt: str):
    """统一封装 LLM 调用逻辑"""
    if model_name == "qwen3-coder-plus":
        response = client.chat.completions.create(
            model=model_name,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            stream=False,
            temperature=0
        )
        return response.choices[0].message.content
    elif model_name == "glm-4.6":
        response = client.chat.completions.create(
            model=model_name,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            thinking={"type": "disabled"},
            temperature=0
        )
        return response.choices[0].message.content
    else:
        raise ValueError(f"[ERROR] Unsupported model: {model_name}")

def save_result(language: str, file_name: str, content: str):
    """保存 LLM 输出结果为 JSON 文件"""
    result_dir = root_dir / "result" / language
    result_dir.mkdir(parents=True, exist_ok=True)

    # 去掉前后可能的 ```json 和 ```
    cleaned = content.strip()
    if cleaned.startswith("```json"):
        cleaned = cleaned[len("```json"):].strip()
    if cleaned.endswith("```"):
        cleaned = cleaned[:-3].strip()

    result_path = result_dir / f"{Path(file_name).stem}.json"
    result_path.write_text(cleaned, encoding="utf-8")
    print(f"[INFO] Saved result to {result_path}")

def detect_language(file_name: str) -> str:
    """根据扩展名识别语言"""
    ext = Path(file_name).suffix.lower()
    if ext in [".c", ".java", ".py", ".ets"]:
        return ext.lstrip(".")
    else:
        print(f"[ERROR] Unsupported file type: {file_name}")
        return ""

# =========================
# Step 6. 主逻辑
# =========================
def main():
    parser = argparse.ArgumentParser(description="Code analysis with LLMs")
    parser.add_argument("model_name", nargs="?", default="qwen3-coder-plus", help="Model name")
    parser.add_argument("source_file", nargs="?", help="Source code file name")
    args = parser.parse_args()

    model_name = args.model_name
    source_file = args.source_file

    if model_name not in VALID_MODELS:
        print(f"[ERROR] Unsupported model: {model_name}")
        return

    client = get_llm_client(model_name)

    # ------------------------------
    # 4.1: 指定单个文件
    # ------------------------------
    if source_file:
        language = detect_language(source_file)
        if not language:
            return

        code_path = root_dir / "data" / language / "code" / source_file
        question_path = root_dir / "question" / language / "question.json"

        print(f"[INFO] Processing file: {code_path}")

        code_text = read_code_with_line_numbers(code_path)
        question = read_question(question_path, code_path)

        user_prompt = f"Code:\n{code_text}\n\nQuestion:\n{question}"

        response = call_llm(model_name, client, system_prompt, user_prompt)
        save_result(language, source_file, response)

    # ------------------------------
    # 4.2: 未指定文件，循环处理所有
    # ------------------------------
    else:
        client = get_llm_client(model_name)
        for lang in ["c", "java", "py", "ets"]:
            code_dir = root_dir / "data" / lang / "code"
            question_path = root_dir / "question" / lang / "question.json"

            if not code_dir.exists():
                print(f"[WARN] {code_dir} not found, skipping.")
                continue

            for code_file in code_dir.glob(f"*.{lang}"):
                print(f"[INFO] Processing file: {code_file}")

                code_text = read_code_with_line_numbers(code_file)
                question = read_question(question_path, code_file)

                user_prompt = f"Code:\n{code_text}\n\nQuestion:\n{question}"
                response = call_llm(model_name, client, system_prompt, user_prompt)
                save_result(lang, code_file.name, response)

    print("[INFO] Test completed!")

# =========================
# 程序入口
# =========================
if __name__ == "__main__":
    main()
