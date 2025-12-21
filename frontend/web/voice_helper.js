// Voice Helper for Flutter Web
// Handles SpeechRecognition and SpeechSynthesis

class VoiceHelper {
    constructor() {
        this.recognition = null;
        this.isListening = false;
        this.onResultCallback = null;
        this.onStateChangeCallback = null;

        this.initSpeechRecognition();
    }

    initSpeechRecognition() {
        if ('SpeechRecognition' in window || 'webkitSpeechRecognition' in window) {
            const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
            this.recognition = new SpeechRecognition();
            this.recognition.continuous = true;
            this.recognition.interimResults = false;
            this.recognition.lang = 'en-US';

            this.recognition.onresult = (event) => {
                const last = event.results.length - 1;
                const text = event.results[last][0].transcript;
                console.log("JS Recognized:", text);
                if (this.onResultCallback) {
                    this.onResultCallback(text);
                }
            };

            this.recognition.onend = () => {
                console.log("JS Recognition ended");
                if (this.isListening) {
                    try {
                        this.recognition.start();
                    } catch (e) {
                        console.error("Restart error:", e);
                    }
                } else {
                    if (this.onStateChangeCallback) this.onStateChangeCallback(false);
                }
            };

            this.recognition.onerror = (event) => {
                console.error("JS Recognition error:", event.error);
                this.isListening = false;
                if (this.onStateChangeCallback) this.onStateChangeCallback(false);
            };
        } else {
            console.warn("Speech Recognition not supported");
        }
    }

    startListening(onResult, onStateChange) {
        this.onResultCallback = onResult;
        this.onStateChangeCallback = onStateChange;
        this.isListening = true;

        if (this.recognition) {
            try {
                this.recognition.start();
                if (this.onStateChangeCallback) this.onStateChangeCallback(true);
            } catch (e) {
                console.error("Start error:", e);
            }
        }
    }

    stopListening() {
        this.isListening = false;
        if (this.recognition) {
            try {
                this.recognition.stop();
                if (this.onStateChangeCallback) this.onStateChangeCallback(false);
            } catch (e) {
                console.error("Stop error:", e);
            }
        }
    }

    speak(text) {
        if ('speechSynthesis' in window) {
            window.speechSynthesis.cancel(); // Stop previous
            const utterance = new SpeechSynthesisUtterance(text);
            utterance.rate = 0.9;
            window.speechSynthesis.speak(utterance);
        }
    }
}

// Global instance
window.voiceHelper = new VoiceHelper();
