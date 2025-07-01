import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeech {
  FlutterTts flutterTts = FlutterTts();
  Future speak(text) async {
    var result = await flutterTts.speak(text);
    return result;
  }
}
