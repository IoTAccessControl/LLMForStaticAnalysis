import os
from pathlib import Path
import json
from analysis import run_llm

root_dir = Path(os.getcwd())

def read_code_with_lineno(path):
    lines = []
    with open(path, "r", encoding="utf-8") as f:
        for i, line in enumerate(f, 1):
            # lines.append(f"{i}: {line.rstrip()}\n")
            lines.append(f"{line.rstrip()}\n")
    return "".join(lines)


def read_question(path):
    if not Path(path).exists():
        print(f"[WARN] {path} does not exist")
        return None
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    return data


def save_result(model, lang, filename, content):
    out_dir = root_dir / "result" / lang
    out_dir.mkdir(parents=True, exist_ok=True)
    clean = content.replace("```json", "").replace("```", "").strip()
    out_path = out_dir / (Path(filename).stem + ".json")

    with open(out_path, "w", encoding="utf-8") as f:
        f.write(clean)


def process_single_file(model, filename, rounds):
    lang = filename.split(".")[-1]

    code_path = root_dir / "data" / lang / "code" / filename
    question_path = root_dir / "question" / lang / "question.json"

    print(f"[INFO] Processing {code_path}")

    code = read_code_with_lineno(code_path)
    question_list = read_question(question_path)
    q = None
    if question_list:
        for item in question_list:
            if item.get("file_name") == filename:
                q = item.get("question")
                break

    if not q:
        print(f"[WARN] No question found for {filename}")
        return

    user_prompt = code + "\n\nQUESTION: " + q
    result = run_llm(model, user_prompt, rounds)
    save_result(model, lang, filename, result)


def process_all_files(model, rounds):
    data_dir = root_dir / "data"
    for lang_dir in data_dir.iterdir():
        if lang_dir.is_dir():
            code_dir = lang_dir / "code"
            for file in code_dir.iterdir():
                process_single_file(model, file.name, rounds)
