class Config {
  // REPLACE '192.168.1.5' with your computer's local IP address.
  // Run 'ipconfig' (Windows) or 'ifconfig' (Mac/Linux) to find it.
  // Example: 'https://192.168.1.10:8000'
  static const String baseUrl = 'https://192.168.1.118:8000'; 
  
  static String get analyzeSceneUrl => '$baseUrl/analyze/scene';
}
