import sys

def refine_markdown(repo_url, mdfile, purpose):
    print(f"Cloning {repo_url}")
    print(f"Refining {mdfile} with purpose: {purpose}")
    # 🔧 Your refining logic goes here

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python md_auto_refine.py <repo> <mdfile> <purpose>")
        sys.exit(1)

    repo = sys.argv[1]
    mdfile = sys.argv[2]
    purpose = sys.argv[3]

    refine_markdown(repo, mdfile, purpose)
