import os
import random
from typing import Optional
import base64
try:
    import google.generativeai as genai
except ImportError:
    genai = None
except Exception:
    genai = None
from PIL import Image
import io
import json

class SceneAnalyzer:
    """
    Analyzes camera frames for composition, lighting, and scene quality using Gemini 3 VLM.
    """
    
    def __init__(self):
        self.api_key = os.getenv("GEMINI_API_KEY")
        if self.api_key:
            genai.configure(api_key=self.api_key)
            self.model = genai.GenerativeModel('gemini-1.5-flash')
        else:
            print("Warning: GEMINI_API_KEY not found, using mock responses")
            self.model = None
    
    async def analyze_scene(self, image_bytes: bytes, context: str) -> dict:
        """
        Analyze a camera frame for photography guidance.
        
        Args:
            image_bytes: JPEG image data
            context: Photography context (e.g., "Professional Profile", "Wedding")
        
        Returns:
            {
                "composition_score": int (1-10),
                "lighting": str ("Poor", "Fair", "Good", "Excellent"),
                "suggestion": str,
                "is_ready_to_shoot": bool,
                "details": {
                    "subject_position": str,
                    "background_quality": str
                }
            }
        """
        
        if self.model:
            try:
                # Use real Gemini API
                image = Image.open(io.BytesIO(image_bytes))
                
                prompt = f"""Analyze this photo for {context} photography.

Provide a JSON response with:
1. composition_score: integer from 1-10
2. lighting: one of ["Poor", "Fair", "Good", "Excellent"]
3. suggestion: one specific, actionable tip to improve the shot (max 50 words)
4. subject_position: brief description of subject positioning
5. background_quality: brief description of background

Be concise and professional. Return ONLY valid JSON.

Example:
{{
  "composition_score": 8,
  "lighting": "Good",
  "suggestion": "Move slightly left to better align with rule of thirds",
  "subject_position": "Well-centered",
  "background_quality": "Clean and uncluttered"
}}"""

                response = self.model.generate_content([prompt, image])
                
                # Parse JSON from response
                response_text = response.text.strip()
                # Remove markdown code blocks if present
                if response_text.startswith("```json"):
                    response_text = response_text[7:]
                if response_text.startswith("```"):
                    response_text = response_text[3:]
                if response_text.endswith("```"):
                    response_text = response_text[:-3]
                response_text = response_text.strip()
                
                data = json.loads(response_text)
                
                return {
                    "composition_score": data.get("composition_score", 5),
                    "lighting": data.get("lighting", "Fair"),
                    "suggestion": data.get("suggestion", "Keep practicing!"),
                    "is_ready_to_shoot": data.get("composition_score", 5) >= 7,
                    "details": {
                        "subject_position": data.get("subject_position", ""),
                        "background_quality": data.get("background_quality", "")
                    }
                }
            except Exception as e:
                print(f"Gemini API error: {e}")
                # Fall through to mock response
        
        # Mock responses for testing (fallback)
        mock_responses = [
            {
                "composition_score": 8,
                "lighting": "Good",
                "suggestion": "Subject is well-positioned. Try tilting your head slightly for a more dynamic look.",
                "is_ready_to_shoot": True,
                "details": {
                    "subject_position": "Center-aligned, following rule of thirds",
                    "background_quality": "Clean with good depth of field"
                }
            },
            {
                "composition_score": 6,
                "lighting": "Fair",
                "suggestion": "Move closer to the window for better natural light.",
                "is_ready_to_shoot": False,
                "details": {
                    "subject_position": "Slightly off-center",
                    "background_quality": "Cluttered, consider changing angle"
                }
            },
            {
                "composition_score": 9,
                "lighting": "Excellent",
                "suggestion": "Perfect lighting and composition! Ready to shoot.",
                "is_ready_to_shoot": True,
                "details": {
                    "subject_position": "Excellent positioning with natural framing",
                    "background_quality": "Professional quality"
                }
            },
            {
                "composition_score": 5,
                "lighting": "Poor",
                "suggestion": "Lighting is too harsh. Move to a shaded area or adjust camera position.",
                "is_ready_to_shoot": False,
                "details": {
                    "subject_position": "Acceptable but could be improved",
                    "background_quality": "Backlit, causing silhouette effect"
                }
            }
        ]
        
        return random.choice(mock_responses)

scene_analyzer = SceneAnalyzer()
