from fastapi import FastAPI, File, UploadFile
import whisper
import uvicorn
import os

app = FastAPI()
model = whisper.load_model("base")  # Choose from: tiny, base, small, medium, large

@app.post("/transcribe/")
async def transcribe_audio(file: UploadFile = File(...)):
    try:
        file_location = f"temp_{file.filename}"
        with open(file_location, "wb") as f:
            f.write(await file.read())

        result = model.transcribe(file_location)
        os.remove(file_location)

        return {"text": result["text"]}
    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
