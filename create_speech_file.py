import sys, os
import pyttsx3
import wave

engine = pyttsx3.init()
engine.setProperty('rate', 150)
engine.setProperty('volume', 1.0)

speech_file_name = sys.argv[2]+".wav"
engine.save_to_file(sys.argv[1], speech_file_name)

print(speech_file_name)
