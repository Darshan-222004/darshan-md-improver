import os
import sys
from openai import OpenAI
from tenacity import retry, stop_after_attempt, wait_exponential

if len(sys.argv) != 3:
    print("Usage: improver.py <markdown_path> <purpose>")
    sys.exit(1)

markdown_path = sys.argv[1]
purpose = sys.argv[2]

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

@retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=4, max=10))
def improve_content(content, purpose):
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[{
            "role": "user",
            "content": f"Improve this markdown for {purpose}:\n\n'''{content}'''"
        }],
        temperature=0.7
    )
    return response.choices[0].message.content

with open(markdown_path, "r") as f:
    content = f.read()

improved = improve_content(content, purpose)

with open(markdown_path, "w") as f:
    f.write(improved)
