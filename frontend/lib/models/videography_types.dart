enum VideographyType {
  cinematic("Cinematic", "A high-end cinematic look with dramatic lighting and 24fps motion"),
  vlog("Vlog", "Bright, clear face-focused lighting for personal storytelling"),
  documentary("Documentary", "Natural, gritty, and realistic style"),
  musicVideo("Music Video", "Dynamic, high-contrast, artistic style"),
  noir("Noir", "High contrast black and white, moody shadows"),
  product("Product", "Clear, well-lit product demonstration video with focus on details and texture"),
  commercial("Commercial", "High-fidelity, crisp lighting, branding focus, and polished transitions"),
  corporate("Corporate", "Professional interviews, B-roll, clean office aesthetics, and clear audio context"),
  realEstate("Real Estate Video", "Smooth gimbal-like pans, wide-angle interior walkthroughs, and drone-like exteriors"),
  wedding("Wedding Highlight", "Emotional storytelling, cinematic highlights, slow-motion grace, and romantic lighting"),
  sports("Sports Action", "High frame rates for slow-motion, subject tracking, and peak action capture"),
  travel("Travel Movie", "Cinematic transitions, vibrant color grading, and cultural immersion storytelling"),
  liveEvent("Live Event", "Multi-cam feel, consistent exposure for stage lighting, and audio sync focus");

  final String label;
  final String promptContext;
  const VideographyType(this.label, this.promptContext);
}
