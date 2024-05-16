import sys, os, io
import base64
import cv2
import numpy as np
from PIL import Image
from langchain_core.tools import tool
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage

#--------------------------------------------------------------------------------------------------

llm = ChatOpenAI(api_key=os.environ['PUPPY_OPENAI_API_KEY'], model="gpt-4-vision-preview", max_tokens=1000)
system_prompt=os.environ['PUPPY_OPENAI_SYSTEM_PROMPT']

#--------------------------------------------------------------------------------------------------

base64_frames = None

def encode_image(image_path):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode("utf-8")

for jpgfile in sys.argv[1:]:
    jpg_as_np = np.frombuffer(base64.b64decode(encode_image(jpgfile)), dtype=np.uint8)
    frame = cv2.imdecode(jpg_as_np, flags=1)
    base64_frames = frame if base64_frames is None else np.hstack((base64_frames, frame))

#--------------------------------------------------------------------------------------------------

img = Image.fromarray(base64_frames)
img_byte_arr = io.BytesIO()
img.save(img_byte_arr, format="JPEG")
img_base64 = base64.b64encode(img_byte_arr.getvalue()).decode("utf-8")

ai_response = llm.invoke(
    [HumanMessage(
        content = [
            {"type": "text", "text": system_prompt},
            {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{img_base64}"}}
        ]
    )]
)

print(ai_response.content)
