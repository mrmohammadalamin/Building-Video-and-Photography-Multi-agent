from .base_agent import BaseAgent
try:
    from google import genai
except ImportError:
    genai = None

class VideographerAgent(BaseAgent):
    def __init__(self):
        super().__init__()
        self.model_id = 'gemini-2.0-flash'

    async def chat_guidance(self, prompt: str) -> str:
        """Generate conversational videography/cinematography guidance"""
        if not self.client:
            return "Action! I'm Gemini 3, your Video Director. What sort of scene are we shooting?"
        
        try:
            response = self.client.models.generate_content(
                model=self.model_id,
                contents=prompt
            )
            return response.text.strip()
        except Exception as e:
            return f"Cut! Director's busy: {str(e)[:40]}. Let's go again!"
