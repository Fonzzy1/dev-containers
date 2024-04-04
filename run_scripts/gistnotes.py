#!/usr/bin/env python3
from sentence_transformers import SentenceTransformer
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from InquirerPy import inquirer
import os
import requests
import tqdm

token = os.environ["GH_TOKEN"]
headers = {"Authorization": "Token " + token}


def list_all_gists(username):
    url = f"https://api.github.com/users/{username}/gists"
    response = requests.get(url, headers=headers)
    gists = response.json()

    ret_dict = {gist["id"]: {} for gist in gists}
    print("Fetching Gists...")
    for gist in tqdm.tqdm(gists, total=len(gists)):
        ret_dict[gist["id"]] = process_gist(gist)
    return ret_dict


def process_gist(gist):
    ret_dict = {}
    ret_dict["description"] = (
        gist["description"]
        if gist["description"] != ""
        else list(gist["files"].keys())[0]
    )
    ret_dict["files"] = list(gist["files"].keys())
    return ret_dict


def get_single_gist(gist_id):
    url = f"https://api.github.com/gists/{gist_id}"
    response = requests.get(url, headers=headers)
    gist = response.json()

    return process_gist(gist)


class EmbeddingFinder:
    def __init__(self, data: dict):
        self.data = data
        print("Loading Model...")
        self.model = SentenceTransformer(
            "all-MiniLM-L6-v2"
        )  # Use a light model for quick embedding

    def prepare_data(self):
        texts = [x["description"] for x in self.data.values()]
        print("Preparing data...")
        raw_embeddings = self.model.encode(
            texts, convert_to_tensor=True, show_progress_bar=True
        )

        for i, k in enumerate(self.data.keys()):
            self.data[k]["embedding"] = raw_embeddings[i].detach().numpy()

    def find(self, query):
        query_embedding = self.model.encode([query], convert_to_tensor=True)

        embeddings_numpy = np.array([x["embedding"] for x in self.data.values()])

        cos_similarities = cosine_similarity(
            query_embedding.detach().numpy(), embeddings_numpy
        ).flatten()

        # cos_similarities will have shape (n_samples,), and argsort returns indices from smallest to largest
        # hence we will want to reverse the order (argsort returns from smallest to largest)
        top_similar_indices = cos_similarities.argsort()[::-1]

        return [list(self.data.keys())[i] for i in top_similar_indices]

    def update_embedding_for_key(self, key):
        if key in self.data:
            text = self.data[key]["description"]
            embedding = (
                self.model.encode([text], convert_to_tensor=True)[0].detach().numpy()
            )
            self.data[key]["embedding"] = embedding


def get_key_from_description(data, target_description):
    for key, value in data.items():
        if "description" in value and value["description"] == target_description:
            return key
    return None


def run_gist_notes(username):

    data = list_all_gists(username)
    finder = EmbeddingFinder(data)
    finder.prepare_data()

    try:
        while True:
            # use InquirerPy
            query = inquirer.text(
                message="What are you looking for?",
            ).execute()

            while True:

                keys = finder.find(query)

                choices = [finder.data[x]["description"] for x in keys] + [
                    "? (Return to search)",
                    "+ (Make New Gist)",
                ]

                question = inquirer.fuzzy(message="Select a gist:", choices=choices)

                result = question.execute()

                if result == "? (Return to search)" or result is None:
                    break
                if result == "+ (Make New Gist)":

                    gist = requests.post(
                        "https://api.github.com/gists",
                        json={
                            "description": query,
                            "public": False,
                            "files": {"notes.md": {"content": f"#{query}"}},
                        },
                        headers=headers,
                    ).json()
                    run_vim(gist["id"], gist["description"])
                    finder.data[gist["id"]] = process_gist(gist)
                    finder.update_embedding_for_key(gist["id"])

                key = get_key_from_description(finder.data, result)

                if key:
                    run_vim(key, finder.data[key]["description"])
                    finder.data[key] = get_single_gist(key)
                    finder.update_embedding_for_key(key)
    except KeyboardInterrupt:
        exit(1)


def run_vim(gist_id, description):

    comments = get_comments(gist_id)
    os.system(f" gh gist clone {gist_id} /gist > /dev/null 2>&1;")
    with open("/gist/.comments.md", "w") as f:
        f.write(comments)
    with open("/gist/.description.txt", "w") as f:
        f.write(description)

    os.system(f"vim")

    new_comments_content = (
        open("/gist/.comments.md", "r")
        .read()
        .split("---------------------------------------------")[-1]
        .lstrip()
    )
    if new_comments_content != "":
        make_new_comment(gist_id, new_comments_content)

    new_description = open("/gist/.description.txt", "r").read().rstrip().lstrip()
    if new_description != description:
        update_gist_desc(gist_id, new_description)

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
    _ = print(f"https://gist.github.com/{gist_id}")


def make_new_comment(gist_id, new_comments_content):
    requests.post(
        f"https://api.github.com/gists/{gist_id}/comments",
        json={"body": new_comments_content},
        headers=headers,
    )
    print("Comment Saved")


def update_gist_desc(gist_id, new_description):
    r = requests.patch(
        f"https://api.github.com/gists/{gist_id}",
        json={"description": new_description},
        headers=headers,
    )
    print("Description Updated")


def get_comments(gist_id):
    raw_comments = requests.get(
        f"https://api.github.com/gists/{gist_id}/comments", headers=headers
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


if __name__ == "__main__":
    run_gist_notes("fonzzy1")
