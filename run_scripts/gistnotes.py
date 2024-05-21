#!/usr/bin/env python3
from sentence_transformers import SentenceTransformer
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from InquirerPy import inquirer
import os
import requests
import tqdm
import shutil
import pyperclip
import yaml
import re


token = os.environ["GH_TOKEN"]
headers = {"Authorization": "Token " + token}
model = SentenceTransformer("all-MiniLM-L6-v2")  # Use a light model for quick embedding


def get_description_from_md(filename):
    with open(filename, "r") as f:
        # Read file contents
        content = f.read()

    # Regular expression matching YAML frontmatter
    match = re.search(r"^---\s*^(.*?)^---\s*(.*)$", content, re.DOTALL | re.MULTILINE)
    if match:
        frontmatter = match.group(1)

        # Parse YAML
        data = yaml.safe_load(frontmatter)

        # Extract and return description
        if "description" in data:
            return data["description"]
    return None


class Wiki:
    def __init__(self):
        os.system("gh repo clone wiki /wiki")
        self.notes = []
        self.get_all_notes()

    def get_all_notes(self):
        for path in os.listdir("/wiki"):
            if not path.startswith("."):  # skip files that start with a '.'
                self.notes.append(Note("/wiki/" + path))


class Note:
    def __init__(self, path):
        self.path = path
        self.name, self.extension = os.path.splitext(os.path.basename(path))
        if self.extension in ("md", "rmd"):
            self.description = get_description_from_md(path)
        else:
            self.description = None
        self.embedable_string = f"{self.name}: {self.description}"
        self.embedding = None

    def __repr__(self):
        return self.name

    def open(self):
        os.system(f"vim {self.path}")

    def delete(self):
        shutil.rmtree(self.path)


class EmbeddingFinder:
    def __init__(self, data: list):
        self.data = data
        print(data)
        print("Loading Model...")

    def find(self, query):
        query_embedding = model.encode([query], convert_to_tensor=True)

        embeddings_numpy = np.array([x.embedding for x in self.data])

        cos_similarities = cosine_similarity(
            query_embedding.detach().numpy(), embeddings_numpy
        ).flatten()

        # cos_similarities will have shape (n_samples,), and argsort returns indices from smallest to largest
        # hence we will want to reverse the order (argsort returns from smallest to largest)
        top_similar_indices = cos_similarities.argsort()[::-1]

        return [self.data[i] for i in top_similar_indices]


def bulk_set_embedding(ls):
    texts = [x.embedable_string for x in ls]
    print("Preparing data...")
    raw_embeddings = model.encode(texts, convert_to_tensor=True, show_progress_bar=True)
    for i, _ in enumerate(ls):
        ls[i].embedding = raw_embeddings[i].detach().numpy()


def run_gist_notes():

    wiki = Wiki()
    return
    print(wiki.notes)

    bulk_set_embedding(wiki.notes)

    try:
        while True:
            # use InquirerPy
            query = inquirer.text(
                message="What are you looking for?",
            ).execute()

            while True:
                finder = EmbeddingFinder(wiki.notes)

                items = finder.find(query)

                choices = [x for x in items] + [
                    "? (Return to search)",
                    "+ (New)",
                ]

                question = inquirer.fuzzy(message="Select a gist:", choices=choices)

                result = question.execute()

                if result == "? (Return to search)" or result is None:
                    break
                elif result == "+ (New)":
                    obj = Note.create_from_name(query)
                    wiki.notes.append(obj)

                else:
                    obj = result

                action_query = inquirer.fuzzy(
                    message=f"What would you like to do with {obj}?",
                    choices=[
                        "Open",
                        "Delete",
                        "Knit to Clipboard",
                        "Knit to Open",
                        "Knit to Gist",
                    ],
                )
                action = action_query.execute()

                if action == "Edit":
                    obj.edit()
                    obj.update_embedding()
                elif action == "Open":
                    obj.open()
                elif action == "Delete":
                    check = input("Are Sure? [y] \n")
                    if check.lower() == "y":
                        obj.delete()
                        if type(obj) == Gist:
                            hub.gists.remove(obj)
                        elif type(obj) == Secret:
                            safe.secrets.remove(obj)
                elif action == "Make Public":
                    if type(obj) == Gist:
                        print(f"{obj} is already Public")
                    elif type(obj) == Secret:
                        safe.secrets.remove(obj)
                        new_gist = Gist.from_secret(obj)
                        new_gist.update_embedding()
                        hub.gists.append(new_gist)
                        obj.delete()
                elif action == "Make Private":
                    if type(obj) == Secret:
                        print(f"{obj} is already Private")
                    elif type(obj) == Gist:
                        hub.gists.remove(obj)
                        new_secret = Secret.from_gist(obj)
                        new_secret.update_embedding()
                        safe.secrets.append(new_secret)
                        obj.delete()
                elif action == "Copy Link":
                    obj.copy_link()
                elif action == "Open Link":
                    obj.open_link()

    except KeyboardInterrupt:
        exit(1)


if __name__ == "__main__":
    run_gist_notes()
