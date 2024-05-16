import sys, os
from openai import OpenAI

client = OpenAI(api_key=os.environ['PUPPY_OPENAI_API_KEY'])
result = client.audio.speech.create(model='tts-1', input=sys.argv[2], voice=os.environ['PUPPY_OPENAI_SPEECH_VOICE'])

speech_file_name = sys.argv[1]+".mp3"
result.write_to_file(speech_file_name)

print(speech_file_name)
