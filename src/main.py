import argparse
from tools import process_single_file, process_all_files


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("model", nargs="?", default="qwen3-coder-plus")
    parser.add_argument("filename", nargs="?")
    parser.add_argument("rounds", nargs="?", type=int, default=1)

    args = parser.parse_args()

    model = args.model
    filename = args.filename
    rounds = args.rounds

    print(f"[INFO] Model: {model}, File: {filename}, Rounds: {rounds}")

    if filename:
        process_single_file(model, filename, rounds)
    else:
        process_all_files(model, rounds)

    print("[INFO] Test completed!")


if __name__ == "__main__":
    main()
