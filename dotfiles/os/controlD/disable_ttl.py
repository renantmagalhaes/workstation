import requests
import time
import argparse
import os


def disable_profile_temporarily(profile_id, api_key, minutes=60):
    url = f"https://api.controld.com/profiles/{profile_id}"
    headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}

    # Calculate the future timestamp
    current_timestamp = int(time.time())
    disable_until = current_timestamp + (minutes * 60)

    payload = {"disable_ttl": str(disable_until)}

    response = requests.put(url, json=payload, headers=headers)
    print(f"Profile Disable: Status Code {response.status_code} - {response.text}")


def main():
    parser = argparse.ArgumentParser(description="Disable profile temporarily.")
    parser.add_argument(
        "minutes",
        type=int,
        nargs="?",
        default=60,
        help="Number of minutes to disable the profile (default: 60)",
    )

    args = parser.parse_args()
    api_key = os.getenv("CONTROLD_API")
    profile_id = os.getenv("CONTROLD_PROFILEID")

    if not api_key or not profile_id:
        print(
            "Error: Missing environment variables CONTROLD_API or CONTROLD_PROFILEID."
        )
        return

    # Disable profile for the specified minutes
    disable_profile_temporarily(profile_id, api_key, minutes=args.minutes)


if __name__ == "__main__":
    main()
