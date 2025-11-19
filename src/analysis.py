import os
from dotenv import load_dotenv
from system_prompt import system_prompt
from memory import ConversationMemory

load_dotenv()

valid_models = ["qwen3-coder-plus", "glm-4.6"]


def run_llm(model, user_prompt, rounds):
    if model not in valid_models:
        print(f"[ERROR] Unsupported model: {model}")
        return ""

    memory = ConversationMemory()
    memory.init(system_prompt, user_prompt)

    reply = ""

    if model == "qwen3-coder-plus":
        from openai import OpenAI
        client = OpenAI(
            api_key=os.getenv("DASHSCOPE_API_KEY"),
            base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",
        )

        for _ in range(rounds):
            resp = client.chat.completions.create(
                model="qwen3-coder-plus",
                messages=memory.get(),
                stream=False,
                temperature=0,
            )
            reply = resp.choices[0].message.content
            memory.append_assistant(reply)

        return reply

    elif model == "glm-4.6":
        from zai import ZhipuAiClient
        client = ZhipuAiClient(api_key=os.getenv("ZHIPU_API_KEY"))

        for _ in range(rounds):
            resp = client.chat.completions.create(
                model="glm-4.6",
                messages=memory.get(),
                thinking={"type": "disabled"},
                temperature=0,
            )
            reply = resp.choices[0].message.content
            memory.append_assistant(reply)

        return reply
