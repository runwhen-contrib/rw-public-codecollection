from enum import Enum

class Check:
    CHECKMARK = '\u2713'
    X = '\u2717'

    def __init__(self, title:str, value=None, symbol=None, description:str="", indented:bool=True, required:bool=False):
        self.title = title
        self.value = value
        self.symbol = symbol
        self.description = description
        self.indented = indented
        self.required = required
        self.passed = None
        self.doc_link = None
        self.commands = []

    def __str__(self):
        check_str = [""]
        if self.indented:
            check_str.append("\t")
        if self.title:
            check_str.append(self.title)
        if self.value:
            check_str.append(self.value)
        if isinstance(self.symbol, bool):
            if self.symbol:
                check_str.append(Check.CHECKMARK)
            if not self.symbol:
                check_str.append(Check.X)
        if self.description:
            check_str.append("\n")
            if self.indented:
                check_str.append("\t")
            check_str.append(self.description)
        return " ".join(check_str)