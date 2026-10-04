class PscError(Exception):
    """A user-facing error. Carries one or more messages."""

    def __init__(self, messages):
        if isinstance(messages, str):
            messages = [messages]
        self.messages = list(messages)
        super().__init__("\n".join(self.messages))


class ErrorCollector:
    """Collects validation errors so a run reports all of them at once."""

    def __init__(self):
        self.messages = []

    def add(self, message):
        self.messages.append(message)

    def extend(self, error: PscError):
        self.messages.extend(error.messages)

    def raise_if_any(self):
        if self.messages:
            raise PscError(self.messages)
