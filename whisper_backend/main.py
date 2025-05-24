from fastapi import FastAPI, File, UploadFile
import whisper
import os
import subprocess
import uuid

app = FastAPI()

# Load the model once during startup
model = whisper.load_model("base")

@app.get("/")
def root():
    return {"message": "Whisper backend is running"}

@app.post("/transcribe/")
async def transcribe_audio(file: UploadFile = File(...)):
    try:
# Save uploaded file
        original_ext = os.path.splitext(file.filename)[-1]
        input_path = f"temp_input{original_ext}"
        with open(input_path, "wb") as f:
            f.write(await file.read())

    # Convert to WAV using ffmpeg
        wav_path = f"temp_output_{uuid.uuid4().hex}.wav"
        ffmpeg_cmd = [
        "ffmpeg", "-y",
        "-i", input_path,
        "-ar", "16000",  # Sample rate for Whisper
        "-ac", "1",      # Mono
        wav_path
        ]
        subprocess.run(ffmpeg_cmd, check=True)

    # Transcribe
        result = model.transcribe(wav_path)

    # Clean up
        os.remove(input_path)
        os.remove(wav_path)

        return {"text": result["text"]}
    except Exception as e:
        return {"error": str(e)}
