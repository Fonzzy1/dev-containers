#!/usr/bin/env python3
from numpy.matrixlib import defmatrix
from scipy.stats import describe
from sentence_transformers import SentenceTransformer
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from InquirerPy import inquirer
import os
import requests
import tqdm
import shutil


token = os.environ["GH_TOKEN"]
headers = {"Authorization": "Token " + token}
model = SentenceTransformer("all-MiniLM-L6-v2")  # Use a light model for quick embedding


class Vault:
    def __init__(self):
        self.location = os.environ["VAULT"]
        self.secrets = []
        self.get_all_secrets()

    def get_all_secrets(self):
        for path in os.listdir(self.location):
            self.secrets.append(Secret.from_path(self.location + "/" + path))


class Secret:
    def __init__(self, description, files, path):
        self.description = description
        self.files = files
        self.path = path
        self.embedding = None

    def __repr__(self):
        return "🔒 " + self.description

    @classmethod
    def from_path(cls, path):
        description = os.path.basename(path)
        files = os.listdir(path)
        path = path
        return cls(description, files, path)

    @classmethod
    def create_from_description(cls, description):
        path = os.environ["VAULT"] + "/" + description
        _ = os.mkdir(path)
        return cls.from_path(path)

    def edit(self):
        with open(f"{self.path}/.description.txt", "w") as f:
            f.write(self.description)

        os.system(f"cd '{self.path}'; vim")

        new_description = (
            open(f"{self.path}/.description.txt", "r").read().rstrip().lstrip()
        )
        if new_description != self.description:
            self.update_desc(new_description)
            self.description = new_description

    def update_desc(self, new_description):
        new_path = os.environ["VAULT"] + "/" + new_description
        shutil.move(self.path, new_path)
        self.path = new_path

    def update_embedding(self):
        raw_embeddings = model.encode(
            [self.description], convert_to_tensor=True, show_progress_bar=False
        )
        self.embedding = raw_embeddings[0].detach().numpy()

    def open(self):
        for file in os.listdir(self.path):
            full_path = self.path + "/" + file
            os.system(f'xdg-open  "{full_path}"')

    def delete(self):
        shutil.rmtree(self.path)


class Github:
    def __init__(self, username):
        self.user_name = username
        self.gists = []
        self.get_all_gists()

    def get_all_gists(self):
        url = f"https://api.github.com/users/{self.user_name}/gists"
        response = requests.get(url, headers=headers)
        raw_gists = response.json()

        print("Fetching Gists...")
        for raw_gist in tqdm.tqdm(raw_gists, total=len(raw_gists)):
            self.gists.append(Gist.from_raw(raw_gist))


class Gist:
    def __init__(self, id, description, files):
        self.id = id
        self.description = description
        self.files = files
        self.embedding = None

    def __repr__(self):
        return self.description

    # Using a class method to create a new Gist instance from raw data
    @classmethod
    def from_raw(cls, raw_dict):
        description = (
            raw_dict["description"]
            if raw_dict["description"] != ""
            else list(raw_dict["files"].keys())[0]
        )
        files = list(raw_dict["files"].keys())
        id = raw_dict["id"]
        return cls(id, description, files)

    @classmethod
    def from_id(cls, id):
        url = f"https://api.github.com/gists/{id}"
        response = requests.get(url, headers=headers)
        raw_gist = response.json()
        return cls.from_raw(raw_gist)

    @classmethod
    def create_from_description(cls, description):
        raw_gist = requests.post(
            "https://api.github.com/gists",
            json={
                "description": description,
                "public": False,
                "files": {"notes.md": {"content": f"#{description}"}},
            },
            headers=headers,
        ).json()
        return cls.from_raw(raw_gist)

    def make_new_comment(self, new_comments_content):
        requests.post(
            f"https://api.github.com/gists/{self.id}/comments",
            json={"body": new_comments_content},
            headers=headers,
        )
        print("Comment Saved")

    def update_gist_desc(self, new_description):
        r = requests.patch(
            f"https://api.github.com/gists/{self.id}",
            json={"description": new_description},
            headers=headers,
        )
        print("Description Updated")

    def get_comments(self):
        raw_comments = requests.get(
            f"https://api.github.com/gists/{self.id}/comments", headers=headers
        ).json()
        comments = [
            {
                "user": x["user"]["login"],
                "comment": x["body"],
                "created": x["created_at"],
            }
            for x in raw_comments
        ]
        out_string = ""
        for comment in comments:
            comment_string = f""" **>> {comment['user']} @ {comment['created']}**\n ---------------------------------------------\n{comment['comment']}\n"""
            out_string += comment_string

        out_string += "\n ---------------------------------------------\n"
        return out_string

    def edit(self):
        os.system(f""" find /gist -mindepth 1 -delete > /dev/null 2>&1; """)
        comments = self.get_comments()
        os.system(f" gh gist clone {self.id} /gist > /dev/null 2>&1;")
        with open("/gist/.comments.md", "w") as f:
            f.write(comments)
        with open("/gist/.description.txt", "w") as f:
            f.write(self.description)

        os.system(f"vim")

        new_comments_content = (
            open("/gist/.comments.md", "r")
            .read()
            .split("---------------------------------------------")[-1]
            .lstrip()
        )
        if new_comments_content != "":
            self.make_new_comment(new_comments_content)

        new_description = open("/gist/.description.txt", "r").read().rstrip().lstrip()
        if new_description != self.description:
            self.update_gist_desc(new_description)
            self.description = new_description

        os.remove("/gist/.comments.md")
        os.remove("/gist/.description.txt")
        _ = os.system(
            f"""
            git add . > /dev/null 2>&1;
            git commit -m "update" > /dev/null 2>&1;
            git push > /dev/null 2>&1;
            """
        )

    def open(self):
        os.system(f""" find /gist -mindepth 1 -delete > /dev/null 2>&1; """)
        os.system(f" gh gist clone {self.id} /gist > /dev/null 2>&1;")
        for file in os.listdir("/gist"):
            if not file.startswith("."):
                full_path = "/gist/" + file
                os.system(f'xdg-open  "{full_path}"')

    def update_embedding(self):
        raw_embeddings = model.encode(
            [self.description], convert_to_tensor=True, show_progress_bar=False
        )
        self.embedding = raw_embeddings[0].detach().numpy()

    def delete(self):
        requests.delete(f"https://api.github.com/gists/{self.id}", headers=headers)


class EmbeddingFinder:
    def __init__(self, data: list):
        self.data = data
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
    texts = [x.description for x in ls]
    print("Preparing data...")
    raw_embeddings = model.encode(texts, convert_to_tensor=True, show_progress_bar=True)
    for i, _ in enumerate(ls):
        ls[i].embedding = raw_embeddings[i].detach().numpy()


def run_gist_notes(username):

    hub = Github(username)
    safe = Vault()

    bulk_set_embedding(hub.gists + safe.secrets)

    try:
        while True:
            # use InquirerPy
            query = inquirer.text(
                message="What are you looking for?",
            ).execute()

            while True:
                finder = EmbeddingFinder(hub.gists + safe.secrets)

                items = finder.find(query)

                choices = [x for x in items] + [
                    "? (Return to search)",
                    "+G (Make New Gist)",
                    "+S (Make New Secret)",
                ]

                question = inquirer.fuzzy(message="Select a gist:", choices=choices)

                result = question.execute()

                if result == "? (Return to search)" or result is None:
                    break
                elif result == "+G (Make New Gist)":
                    obj = Gist.create_from_description(query)
                    hub.gists.append(obj)
                elif result == "+S (Make New Secret)":
                    obj = Secret.create_from_description(query)
                    safe.secrets.append(obj)

                else:
                    obj = result

                action_query = inquirer.fuzzy(
                    message=f"What would you like to do with {obj}?",
                    choices=[
                        "Edit",
                        "Open",
                        "Delete",
                        "Make Public",
                        "Make Private",
                        "Copy Link",
                        "Open Link",
                    ],
                )
                action = action_query.execute()

                if action == "Edit":
                    obj.edit()
                    obj.update_embedding()
                elif action == "Open":
                    obj.open()
                elif action == "Delete":
                    check = input("Are Sure? [y]")
                    if not check.lower() == "y":
                        obj.delete()
                        if obj in hub.gists:
                            hub.gists.remove(obj)
                        elif obj in safe.secrets:
                            safe.secrets.remove(obj)
                elif action == "Make Public":
                    if type(obj) == Gist:
                        print(f"{obj} is already Public")
                    else:
                        new_gist = Gist.from_secret(obj)
                        hub.gists.append(new_gist)
                        obj.delete()
                        safe.secrets.remove(obj)
                elif action == "Make Private":
                    if type(obj) == Gist:
                        print(f"{obj} is already Private")
                    else:
                        new_secret = Secret.from_gist(obj)
                        safe.secrets.append(new_secret)
                        obj.delete()
                        hub.gists.remove(obj)
                elif action == "Copy Link":
                    obj.copy_link()
                elif action == "Open Link":
                    obj.open_link()

    except KeyboardInterrupt:
        exit(1)


if __name__ == "__main__":
    run_gist_notes("fonzzy1")
