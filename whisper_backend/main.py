from fastapi import FastAPI, File, UploadFile
import whisper
import uvicorn
import os
import aiofiles
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Enable CORS for all origins (for frontend use)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

model = whisper.load_model("base")  # options: tiny, base, small, medium, large

@app.post("/transcribe/")
async def transcribe_audio(file: UploadFile = File(...)):
    file_location = f"temp_{file.filename}"
    try:
        async with aiofiles.open(file_location, 'wb') as out_file:
            content = await file.read()
            await out_file.write(content)

        result = model.transcribe(file_location)
        os.remove(file_location)

        return {"text": result["text"]}
    except Exception as e:
        if os.path.exists(file_location):
            os.remove(file_location)
        return {"error": str(e)}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
