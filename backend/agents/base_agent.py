from abc import ABC, abstractmethod
import os
try:
    from google import genai
except ImportError:
    genai = None

from dotenv import load_dotenv

load_dotenv()

class BaseAgent(ABC):
    def __init__(self):
        self.api_key = os.getenv("GOOGLE_API_KEY")
        self.client = None
        if self.api_key:
            print(f"DEBUG: GOOGLE_API_KEY found (starts with {self.api_key[:4]}...)")
            if genai:
                try:
                    self.client = genai.Client(api_key=self.api_key)
                    print("DEBUG: Gemini client initialized successfully.")
                except Exception as e:
                    print(f"DEBUG: Error initializing Gemini client: {e}")
            else:
                print("DEBUG: Warning: google-genai not installed.")
        else:
            print("DEBUG: Warning: GOOGLE_API_KEY not found in environment variables.")

    @abstractmethod
    async def process(self, *args, **kwargs):
        pass
