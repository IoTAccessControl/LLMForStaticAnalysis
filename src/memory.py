class ConversationMemory:
    def __init__(self):
        self.messages = []

    def init(self, system_prompt, user_prompt):
        self.messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ]

    def append_assistant(self, content):
        self.messages.append({"role": "assistant", "content": content})

    def append_user(self, content):
        self.messages.append({"role": "user", "content": content})

    def get(self):
        return self.messages
