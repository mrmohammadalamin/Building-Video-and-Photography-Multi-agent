from enum import Enum
from pydantic import BaseModel

class AppMode(str, Enum):
    PHOTOGRAPHY = "photography"
    VIDEOGRAPHY = "videography"

class ModeState(BaseModel):
    current_mode: AppMode
    is_recording: bool = False
    active_features: list[str] = []

class ModeController:
    def __init__(self):
        self._state = ModeState(current_mode=AppMode.PHOTOGRAPHY)

    def set_mode(self, mode: AppMode) -> ModeState:
        self._state.current_mode = mode
        self._update_features()
        return self._state

    def get_state(self) -> ModeState:
        return self._state

    def _update_features(self):
        if self._state.current_mode == AppMode.PHOTOGRAPHY:
            self._state.active_features = ["scene_analysis", "composition_guide", "shutter_control"]
        else:
            self._state.active_features = ["video_stabilization", "audio_monitoring", "continuous_focus"]

mode_controller = ModeController()
