import os
import re


def find_dart_strings(root_dir):
    dart_strings = []
    # Corrected regex pattern
    pattern = re.compile(r"""("(?:[^"\\]|\\.)*")|('(?:[^\'\\]|\\.)*')""")

    for foldername, subfolders, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename.endswith(".dart"):
                filepath = os.path.join(foldername, filename)
                try:
                    with open(filepath, "r", encoding="utf-8") as file:
                        content = file.read()
                        matches = pattern.findall(content)
                        for match in matches:
                            dart_strings.extend([m for m in match if m])
                except Exception as e:
                    print(f"Error reading {filepath}: {e}")
    return dart_strings


def save_strings_to_file(strings, output_file):
    with open(output_file, "w", encoding="utf-8") as file:
        for string in strings:
            file.write(string + "\n")


if __name__ == "__main__":
    root_directory = os.getcwd()
    output_filename = "dart_strings.txt"

    strings = find_dart_strings(root_directory)
    save_strings_to_file(strings, output_filename)

    print(f"Found {len(strings)} strings. Saved to {output_filename}")
