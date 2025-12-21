from .analyst_agent import AnalystAgent
from .editor_agent import EditorAgent
from .guide_agent import GuideAgent
from PIL import Image

class AgentOrchestrator:
    def __init__(self):
        self.analyst = AnalystAgent()
        self.editor = EditorAgent()
        self.guide = GuideAgent()

    async def analyze_photo(self, image: Image.Image, context: str) -> dict:
        return await self.analyst.process(image, context)

    async def edit_photo(self, prompt: str, image_data: bytes) -> dict:
        return await self.editor.process(prompt, image_data)

    async def generate_guide(self, context: str) -> dict:
        return await self.guide.process(context)

    async def apply_effect(self, image: Image.Image, prompt: str) -> dict:
        """New: Apply real-time Imagen 4 effects"""
        return await self.editor.process_effect(image, prompt)

    async def apply_video_effect(self, context: str, prompt: str) -> dict:
        """New: Apply real-time Veo 3 effects"""
        return await self.guide.process_video_effect(context, prompt)
