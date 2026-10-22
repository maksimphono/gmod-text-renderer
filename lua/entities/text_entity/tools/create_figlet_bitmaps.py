from pyfiglet import Figlet
import re
import json
import string

figlet = Figlet(font='letters')

def get_bitmap(letter):
    text = figlet.renderText(letter)
    if "\n" not in text:
        return ("", 0, 0)
    width = text.index("\n")
    height = text.count("\n")
    bitmap = []

    i = 0
    j = 0
    for sym in text:
        if sym == "\n": 
            j += 1
            i = 0
            continue
        elif sym != " ": bitmap.append([i, j])
        i += 1

    return (bitmap, width, height)

def create_letter_representation(letter):
    bitmap, width, height = get_bitmap(letter)

    return {"letter" : letter, "bitmap" : bitmap, "width" : width, "height" : height}

def to_lua(representations):
    table = []
    depricated = list("\t\n")

    def format(key, value):
        table_entry_fmt = "[\"{key}\"] = @ {value} &"
        return table_entry_fmt.format(key = key, value = value).replace("@", "{").replace("&", "}")

    for repr in filter(lambda repr: repr["letter"] not in depricated, representations.values()):
        value = []
        for k, v in repr.items():
            fmt = ""
            if isinstance(v, str):
                fmt = "[\"{key}\"]=\"{value}\""
            else:
                fmt = "[\"{key}\"]={value}"

            if isinstance(v, list):
                v = str(v).replace("[", "{").replace("]", "}")

            value.append(fmt.format(key = k.replace("\\", "\\\\"), value = v).replace("\n", "\\n"))

        table.append(format(key = repr["letter"].replace("\\", "\\\\"), value = ",".join(value)))

    return ",\n".join(table)

representations = {}

for letter in string.printable[:]:
    repr = create_letter_representation(letter)

    representations[letter] = repr
    
    #print(repr["bitmap"])

with open("symbols_table.lua", "w") as file:
    print(to_lua(representations), file = file)

#with open("figlet_bitmaps.json", "w") as file:
#    json.dump(representations, fp = file, indent=4)