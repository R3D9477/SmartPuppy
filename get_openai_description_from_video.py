import sys, os
import base64
import cv2
from openai import OpenAI

video = cv2.VideoCapture(sys.argv[1])

base64_frames = []
while video.isOpened():
    success, frame = video.read()
    if not success:
        break
    _, buffer = cv2.imencode(".jpg", frame)
    base64_frames.append(base64.b64encode(buffer).decode("utf-8"))

video.release()

PROMPT_MESSAGES = [
    {
        "role": "user",
        "content": [
            os.environ['PUPPY_OPENAI_SYSTEM_PROMPT'],
            *map(lambda x: {"image": x, "resize": 768}, base64_frames[0::50]),
        ],
    },
]
params = {
    "model": "gpt-4-vision-preview",
    "messages": PROMPT_MESSAGES,
    "max_tokens": 200,
}

client = OpenAI(api_key=os.environ['PUPPY_OPENAI_API_KEY'])
result = client.chat.completions.create(**params)

print(result.choices[0].message.content)
