from sentence_transformers import SentenceTransformer
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from InquirerPy import inquirer
import os
import requests


def list_all_gists(username):
    token = os.environ["GH_TOKEN"]
    url = f"https://api.github.com/users/{username}/gists"
    headers = {"Authorization": "Token " + token}
    response = requests.get(url, headers=headers)
    gists = response.json()
    print(gists)

    ret_dict = {gist["id"]: {} for gist in gists}
    for gist in gists:
        ret_dict[gist["id"]]["description"] = (
            gist["description"]
            if gist["description"] != ""
            else list(gist["files"].keys())[0]
        )
        ret_dict[gist["id"]]["text"] = "\n".join(
            [
                f'{requests.get(fileinfo["raw_url"], headers=headers).text}'
                for filename, fileinfo in gist["files"].items()
                if fileinfo["type"] == "text/plain"
            ]
        )

    return ret_dict


class EmbeddingFinder:
    def __init__(self, data: dict):
        self.data = data
        print("Loading Model...")
        self.model = SentenceTransformer(
            "all-MiniLM-L6-v2"
        )  # Use a light model for quick embedding

    def prepare_data(self):
        texts = list([x["text"] for x in self.data.values()])
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
            result = inquirer.text(
                message="What are you looking for?",
            ).execute()

            keys = finder.find(result)

            choices = [data[x]["description"] for x in keys]

            while True:
                question = inquirer.fuzzy(
                    message="Select a gist:",
                    choices=choices + ["? (Return to search)"],
                )

                result = question.execute()

                if result == "? (Return to search)" or result is None:
                    break

                key = get_key_from_description(data, result)

                if key:
                    os.system(
                        f"""
                    gh gist clone {key} /gist; vim -O /gist/*;
                    git add .;
                    git commit -m "update";
                    git push;
                    find /gist -mindepth 1 -delete;
                    """
                    )
    except KeyboardInterrupt:
        exit(1)


if __name__ == "__main__":
    run_gist_notes("fonzzy1")
