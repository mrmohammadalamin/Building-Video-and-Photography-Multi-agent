from .base_agent import BaseAgent
try:
    from google import genai
    from google.genai import types
except ImportError:
    genai = None

from PIL import Image

class AnalystAgent(BaseAgent):
    def __init__(self):
        super().__init__()
        self.model_id = 'gemini-2.0-flash' # Using flash for real-time guidance speed

    async def process(self, image: Image.Image, context: str) -> dict:
        """
        Analyzes the image using Gemini 2.0 Flash for real-time guidance.
        """
        if not self.client:
            return {
                "composition_score": 70,
                "suggestion": "[MOCK] Gemini client not initialized. Check API Key.",
                "lighting": "Unknown",
                "is_ready_to_shoot": False
            }

        prompt = f"""
        You are 'Gemini 3', an expert AI Director and Photography Coach.
        The user is currently capturing: '{context}'.
        
        CRITICAL: If context is 'Product Photography', ensure you direct the user specifically on:
        - Centering the product.
        - Avoiding harsh glares or deep shadows.
        - Ensuring the background is clean and non-distracting.
        - Checking if the branding is visible and sharp.

        Analyze the image frame from the live feed and provide:
        1. A quality score (0-100).
        2. A SHORT, SPOKEN instruction to improve the shot immediately (max 10 words). This will be read aloud to the user via TTS. Examples: "Move closer", "Tilt camera up", "Hold steady", "Good light, take the shot!".
        3. A brief status of lighting.
        4. Whether the shot is ready.
        5. Recommended Technical Adjustments for the camera (to be applied automatically or manually):
           - zoom_level (float: 1.0 to 5.0, where 1.0 is default)
           - exposure_offset (float: -2.0 to 2.0, where 0.0 is default)
           - torch_on (boolean: true if extra light is needed)
        
        If the shot is perfect, say "Perfect, capture now!".
        
        Return the response in JSON format keys:
        {
            "composition_score": 85,
            "suggestion": "Tilt up slightly, frame the subject.",
            "lighting": "Soft and balanced",
            "is_ready_to_shoot": true,
            "technical_adjustments": {
                "zoom_level": 1.1,
                "exposure_offset": 0.0,
                "torch_on": false
            }
        }
        """
        
        try:
            # google-genai SDK 0.6.0+ format
            response = self.client.models.generate_content(
                model=self.model_id,
                contents=[prompt, image]
            )
            
            import json
            try:
                # Clean up response text for JSON parsing
                text = response.text
                if "```json" in text:
                    text = text.split("```json")[-1].split("```")[0].strip()
                elif "```" in text:
                    text = text.split("```")[-1].split("```")[0].strip()
                
                data = json.loads(text)
                return data
            except Exception as e:
                print(f"JSON Parsing Error: {e}")
                return {
                    "composition_score": 75,
                    "suggestion": f"Director: {response.text[:50]}...",
                    "lighting": "Analyzing...",
                    "is_ready_to_shoot": False
                }
        except Exception as e:
            print(f"Gemini API Error: {e}")
            return {
                "composition_score": 0,
                "suggestion": f"Technical issue: {str(e)[:40]}",
                "lighting": "Error",
                "is_ready_to_shoot": False
            }

    async def chat_guidance(self, prompt: str) -> str:
        """Generate conversational photography guidance"""
        if not self.client:
            return "Hi! I'm Gemini 3. I'm ready to help you take professional photos. What are we shooting today?"
        
        try:
            response = self.client.models.generate_content(
                model=self.model_id,
                contents=prompt
            )
            return response.text.strip()
        except Exception as e:
            return f"Director is busy: {str(e)[:40]}. Let's try again!"
