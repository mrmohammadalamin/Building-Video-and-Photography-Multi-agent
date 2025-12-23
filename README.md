# Gemini 3 Video and Photography Agent

A next-generation Video and photography assistant powered by **Gemini 3** (via Gemini 1.5 Pro API), **Gemini Nano**, **Imagen 3**, and **Veo**.

## Prerequisites
- **Python 3.9+**
- **Flutter SDK** (Latest Stable)
- **Google AI API Key** (Get one at [aistudio.google.com](https://aistudio.google.com))

## 1. Backend Setup (FastAPI)

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Create a virtual environment (optional but recommended):
   ```bash
   python -m venv venv
   # Windows:
   .\venv\Scripts\activate
   # Mac/Linux:
   source venv/bin/activate
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. **IMPORTANT**: Set your API Key in `.env`:
   - Open `backend/.env` and replace `your_api_key_here` with your actual Google AI API Key.
   - *Note: The `.env` file is git-ignored for security.*

5. Run the server:
   ```bash
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```
   The API will be available at `http://localhost:8000`.

## 2. Frontend Setup (Flutter)
...
## Project Structure
- `backend/main.py`: FastAPI server entry point.
# Gemini 3 Photography Agent

A next-generation photography assistant powered by **Gemini 3** (via Gemini 1.5 Pro API), **Gemini Nano**, **Imagen 3**, and **Veo**.

## Prerequisites
- **Python 3.9+**
- **Flutter SDK** (Latest Stable)
- **Google AI API Key** (Get one at [aistudio.google.com](https://aistudio.google.com))

## 1. Backend Setup (FastAPI)

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Create a virtual environment (optional but recommended):
   ```bash
   python -m venv venv
   # Windows:
   .\venv\Scripts\activate
   # Mac/Linux:
   source venv/bin/activate
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. **IMPORTANT**: Set your API Key in `.env`:
   - Open `backend/.env` and replace `your_api_key_here` with your actual Google AI API Key.
   - *Note: The `.env` file is git-ignored for security.*

5. Run the server:
   ```bash
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```
   The API will be available at `http://localhost:8000`.

## 2. Frontend Setup (Flutter)
...
## Project Structure
- `backend/main.py`: FastAPI server entry point.
- `backend/agents/`: **Multi-Agent System** modules.
  - `orchestrator.py`: Central agent managing sub-agents.
  - `analyst_agent.py`: Gemini 3 (1.5 Pro) for analysis.
  - `editor_agent.py`: Imagen 3 for editing.
  - `guide_agent.py`: Veo for video guides.
- `backend/.env`: Secure API key storage.
- `frontend/lib/services/ai_service.dart`: Service layer handling API communication.

## Troubleshooting
### "adk" command not found
If you see `adk : The term 'adk' is not recognized`, it means the installation folder is not in your PATH.
You can run it using the full path:
```powershell
C:\Users\mrmoh\AppData\Roaming\Python\Python313\Scripts\adk.exe web
```
Or add `C:\Users\mrmoh\AppData\Roaming\Python\Python313\Scripts` to your System PATH.

### Camera Issues on Chrome
If you see "Camera Not Accessible":
1.  Check the browser address bar for a **blocked camera icon**. Click it and select "Always allow".
2.  Ensure no other app (Zoom, Teams) is using the camera.
3.  Click **"Use Mock Mode"** in the app to test AI features without a camera.
- `frontend/lib/main.dart`: Flutter app entry point.

### Video Demo

Here is a video demo of the application:
[![Video and Photography AI  agent Demo](https://img.youtube.com/vi/MibL8O5Ff_4/0.jpg)](https://youtu.be/FjI1UR5Y5_k)
