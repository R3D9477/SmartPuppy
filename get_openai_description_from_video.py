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

frame_index=0
frames_count=0
video = cv2.VideoCapture(sys.argv[1])
while video.isOpened() and frames_count < 25:
    success, frame = video.read()
    if not success:
        break
    if frame_index == 0:
        width, height, _ = frame.shape
        if width > 1280 or height > 720:
            frame = cv2.resize(frame, (1280, 720))
        base64_frames = frame if base64_frames is None else np.hstack((base64_frames, frame))
        frames_count=frames_count+1
    frame_index=frame_index+1
    if frame_index == 50:
        frame_index = 0
video.release()

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
