#!/usr/bin/env python3
from numpy.matrixlib import defmatrix
from sentence_transformers import SentenceTransformer
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from InquirerPy import inquirer
import os
import requests
import tqdm
from uuid import uuid4

token = os.environ["GH_TOKEN"]
headers = {"Authorization": "Token " + token}


class Vault:
    def __init__(self):
        pass


class Secret:
    def __init__(self, description, files, path):
        self.description = description
        self.files = files
        self.path = path
        self.embedding = None


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

    def open(self):
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
            find /gist -mindepth 1 -delete > /dev/null 2>&1;
            """
        )


class EmbeddingFinder:
    def __init__(self, data: list):
        self.data = data
        print("Loading Model...")
        self.model = SentenceTransformer(
            "all-MiniLM-L6-v2"
        )  # Use a light model for quick embedding

    def prepare_data(self):
        texts = [x.description for x in self.data]
        print("Preparing data...")
        raw_embeddings = self.model.encode(
            texts, convert_to_tensor=True, show_progress_bar=True
        )

        for i, _ in enumerate(self.data):
            self.data[i].embedding = raw_embeddings[i].detach().numpy()

    def find(self, query):
        query_embedding = self.model.encode([query], convert_to_tensor=True)

        embeddings_numpy = np.array([x.embedding for x in self.data])

        cos_similarities = cosine_similarity(
            query_embedding.detach().numpy(), embeddings_numpy
        ).flatten()

        # cos_similarities will have shape (n_samples,), and argsort returns indices from smallest to largest
        # hence we will want to reverse the order (argsort returns from smallest to largest)
        top_similar_indices = cos_similarities.argsort()[::-1]

        return [self.data[i] for i in top_similar_indices]

    def update_embedding_for_description(self, key):
        for index, item in enumerate(self.data):
            if item.description == key:
                i, obj = index, item
        raw_embeddings = self.model.encode(
            [obj.description], convert_to_tensor=True, show_progress_bar=True
        )

        self.data[i].embedding = raw_embeddings[0].detach().numpy()


def run_gist_notes(username):

    hub = Github(username)
    finder = EmbeddingFinder(hub.gists)
    finder.prepare_data()

    try:
        while True:
            # use InquirerPy
            query = inquirer.text(
                message="What are you looking for?",
            ).execute()

            while True:

                items = finder.find(query)

                choices = [x for x in items] + [
                    "? (Return to search)",
                    "+ (Make New Gist)",
                ]

                question = inquirer.fuzzy(message="Select a gist:", choices=choices)

                result = question.execute()

                if result == "? (Return to search)" or result is None:
                    break
                elif result == "+ (Make New Gist)":
                    new_gist = Gist.create_from_description(query)
                    finder.data.append(new_gist)

                else:
                    obj = result

                ## Run vim
                obj.open()

                finder.update_embedding_for_description(obj.description)

    except KeyboardInterrupt:
        exit(1)


if __name__ == "__main__":
    run_gist_notes("fonzzy1")
