import io
from typing import List, Optional
from fastapi import FastAPI, UploadFile, File, Form, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os
from pydantic import BaseModel, Field
from PIL import Image
from agents.orchestrator import AgentOrchestrator

app = FastAPI(title="Gemini 3 Photography Agent API (Multi-Agent)")

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Orchestrator
orchestrator = AgentOrchestrator()

# Create static directory for effects
static_dir = os.path.join(os.path.dirname(__file__), "static")
os.makedirs(os.path.join(static_dir, "effects"), exist_ok=True)
app.mount("/static", StaticFiles(directory=static_dir), name="static")

class TechnicalAdjustments(BaseModel):
    zoom_level: float = 1.0
    exposure_offset: float = 0.0
    torch_on: bool = False

class AnalysisResponse(BaseModel):
    composition_score: int
    suggestion: str
    lighting: str
    is_ready_to_shoot: bool
    technical_adjustments: TechnicalAdjustments = Field(default_factory=TechnicalAdjustments)

class EditResponse(BaseModel):
    edited_image_url: str

class GuideResponse(BaseModel):
    video_url: str

class EffectResponse(BaseModel):
    effect_type: str
    status: str
    overlay_url: str

class VideoEffectResponse(BaseModel):
    effect_type: str
    veo_overlay_stream: str
    metadata: dict

@app.get("/")
async def root():
    return {"message": "Gemini 3 Multi-Agent System is running"}

@app.post("/analyze", response_model=AnalysisResponse)
async def analyze_image(
    context: str = Form(...),
    file: UploadFile = File(...)
):
    try:
        contents = await file.read()
        image = Image.open(io.BytesIO(contents))
        
        result = await orchestrator.analyze_photo(image, context)
        return AnalysisResponse(**result)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/edit", response_model=EditResponse)
async def edit_image(
    prompt: str = Form(...),
    file: UploadFile = File(...)
):
    try:
        contents = await file.read()
        result = await orchestrator.edit_photo(prompt, contents)
        return EditResponse(**result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/apply_effect", response_model=EffectResponse)
async def apply_effect(
    effect_type: str = Form(...),
    custom_prompt: Optional[str] = Form(None),
    file: UploadFile = File(...)
):
    print(f"DEBUG: Received apply_effect request. Type: {effect_type}, Custom: {custom_prompt}")
    try:
        contents = await file.read()
        image = Image.open(io.BytesIO(contents))
        prompt = custom_prompt if custom_prompt else effect_type
        print(f"DEBUG: Processing effect with prompt: {prompt}")
        result = await orchestrator.apply_effect(image, prompt)
        print(f"DEBUG: Effect result result: {result}")
        return EffectResponse(**result)
    except Exception as e:
        print(f"DEBUG: Error in apply_effect: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/video_effect", response_model=VideoEffectResponse)
async def apply_video_effect(
    effect_type: str = Form(...),
    custom_prompt: Optional[str] = Form(None),
    context: str = Form("advertising")
):
    print(f"DEBUG: Received video_effect request. Type: {effect_type}, Custom: {custom_prompt}")
    try:
        prompt = custom_prompt if custom_prompt else effect_type
        result = await orchestrator.apply_video_effect(context, prompt)
        print(f"DEBUG: Video effect result: {result}")
        return VideoEffectResponse(**result)
    except Exception as e:
        print(f"DEBUG: Error in video_effect: {e}")
        raise HTTPException(status_code=500, detail=str(e))

class ChatMessage(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    message: str
    history: List[ChatMessage] = []
    context: str = "Professional Profile"

class ChatResponse(BaseModel):
    text: str
    action: str = None

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """Handle conversational AI photography coaching"""
    try:
        # Build conversation context
        conversation = "\n".join([
            f"{'User' if msg.role == 'user' else 'AI'}: {msg.content}"
            for msg in request.history[-5:]  # Last 5 messages for context
        ])
        
        # Determine functionality based on context/mode (simple heuristic for now)
        is_video_mode = "video" in request.context.lower() or "cinematographer" in request.context.lower()

        if is_video_mode:
            from agents.videographer_agent import VideographerAgent
            agent = VideographerAgent()
            
            system_prompt = f"""You are an expert AI Cinematographer and Director (Gemini 3).
The user is recording a video in the context of: {request.context}.

Direct the user with professional filmmaking advice:
- Camera movement (pan, tilt, dolly, truck)
- Framing (wide, medium, close-up)
- Lighting for video
- Acting direction

Commands to recognize:
- "Action" or "Start" -> respond with action: "start_recording"
- "Cut" or "Stop" -> respond with action: "stop_recording"

Keep responses concise (1-2 sentences). Act like a professional director on set.

Previous conversation:
{conversation}

User: {request.message}
Director AI:"""

        else:
            # Default to Photographer
            from agents.analyst_agent import AnalystAgent
            agent = AnalystAgent()
            
            system_prompt = f"""You are an expert AI photography coach helping users take better photos in the context of: {request.context}.

Be conversational, encouraging, and helpful. Give specific actionable advice about:
- Lighting, composition, posing
- When to take a photo (respond with action: "capture_photo")
- What adjustments to make

Keep responses concise (2-3 sentences). When you think it's the right moment to capture a photo, include the word CAPTURE in your response.

Previous conversation:
{conversation}

User: {request.message}
AI:"""
        
        # Generate conversational response
        response_text = await agent.chat_guidance(system_prompt)
        
        # Detect actions
        action = None
        if "start_recording" in response_text.lower() or "action" in response_text.lower():
             action = "start_recording"
        elif "stop_recording" in response_text.lower() or "cut" in response_text.lower():
             action = "stop_recording"
        elif "capture" in response_text.lower() or "take a photo" in response_text.lower():
             action = "capture_photo"
        
        # Clean up response text if needed (removing keywords might be excessive if they are part of natural speech, keeping it simple)
        response_text = response_text.replace("CAPTURE", "").strip()
        
        return ChatResponse(text=response_text, action=action)
        
    except Exception as e:
        return ChatResponse(text="I'm having trouble right now. Could you rephrase that?", action=None)

@app.post("/guide", response_model=GuideResponse)
async def generate_guide(
    context: str = Form(...)
):
    try:
        result = await orchestrator.generate_guide(context)
        return GuideResponse(**result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Scene Analysis for Proactive Guidance
from services.scene_analyzer import scene_analyzer

class SceneAnalysisResponse(BaseModel):
    composition_score: int
    lighting: str
    suggestion: str
    is_ready_to_shoot: bool

@app.post("/analyze/scene", response_model=SceneAnalysisResponse)
async def analyze_scene(
    context: str = Form(...),
    file: UploadFile = File(...)
):
    """Real-time scene analysis for proactive photography guidance"""
    try:
        contents = await file.read()
        result = await scene_analyzer.analyze_scene(contents, context)
        return SceneAnalysisResponse(
            composition_score=result["composition_score"],
            lighting=result["lighting"],
            suggestion=result["suggestion"],
            is_ready_to_shoot=result["is_ready_to_shoot"]
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Mode Management Endpoints
from services.mode_controller import mode_controller, AppMode, ModeState

@app.post("/mode/set", response_model=ModeState)
async def set_mode(mode: AppMode):
    return mode_controller.set_mode(mode)

@app.get("/mode/current", response_model=ModeState)
async def get_mode():
    return mode_controller.get_state()

if __name__ == "__main__":
    import uvicorn
    import os

    # Check for SSL certs in frontend directory (common for this project structure)
    cert_path = "../frontend/cert.pem"
    key_path = "../frontend/key.pem"
    
    # Fallback to current directory
    if not os.path.exists(cert_path):
        cert_path = "cert.pem"
        key_path = "key.pem"

    if os.path.exists(cert_path) and os.path.exists(key_path):
        print(f"Starting secure backend on https://0.0.0.0:8000 using certs from {cert_path}")
        uvicorn.run(app, host="0.0.0.0", port=8000, ssl_keyfile=key_path, ssl_certfile=cert_path)
    else:
        print("Warning: No SSL certificates found. Starting in HTTP mode. Camera access may be blocked on mobile.")
        uvicorn.run(app, host="0.0.0.0", port=8000)
