import requests
import os
import argparse


def get_folder_id(profile_id, api_key):
    url = f"https://api.controld.com/profiles/{profile_id}/groups"
    headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}

    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        folders = response.json().get("body", {}).get("groups", [])
        for folder in folders:
            if (
                folder["group"] == "AllowList"
            ):  # Ensure this matches your actual folder name
                return folder["PK"]
    else:
        print("Failed to retrieve folders:", response.status_code, response.text)
        return None


def add_allow_rule(profile_id, api_key, domain, folder_id):
    url = f"https://api.controld.com/profiles/{profile_id}/rules"
    headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}

    payload = {
        "do": 1,  # 1 = BYPASS
        "status": 1,
        "group": folder_id,
        "hostnames": [domain],  # Note the plain "hostnames" instead of "hostnames[]"
    }

    response = requests.post(url, json=payload, headers=headers)
    print(f"Add Rule: Status Code {response.status_code} - {response.text}")


def main():
    parser = argparse.ArgumentParser(description="Add a website to AllowList.")
    parser.add_argument("domain", type=str, help="Domain to allow")

    args = parser.parse_args()
    api_key = os.getenv("CONTROLD_API")
    profile_id = os.getenv("CONTROLD_PROFILEID")

    if not api_key or not profile_id:
        print(
            "Error: Missing environment variables CONTROLD_API or CONTROLD_PROFILEID."
        )
        return

    folder_id = get_folder_id(profile_id, api_key)
    if folder_id:
        add_allow_rule(profile_id, api_key, args.domain, folder_id)
    else:
        print("AllowList folder not found.")


if __name__ == "__main__":
    main()

