# main.py
from fastapi import FastAPI, UploadFile, File
import whisper
import os
import tempfile

app = FastAPI()
model = whisper.load_model("base")  # or "tiny", "small", etc. depending on performance

@app.get("/")
async def root():
    return {"message": "Whisper backend is running."}

@app.post("/transcribe/")
async def transcribe_audio(file: UploadFile = File(...)):
    with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as temp_audio:
        temp_audio.write(await file.read())
        temp_audio_path = temp_audio.name

    result = model.transcribe(temp_audio_path)
    os.remove(temp_audio_path)
    return {"transcription": result["text"]}
