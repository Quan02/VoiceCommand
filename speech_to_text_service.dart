import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextService {
  static final SpeechToText speech = SpeechToText();

  static Future<void> startRecording() async {
    await speech.initialize();
    await speech.listen(onResult: (result) {
      print('Speech result: $result');
    });
  }

  static void stopRecording() {
    speech.stop();
  }

}