import 'package:speech_to_text/speech_to_text.dart';

class Controller {
  static var obj = Controller();

  String data="";
  final SpeechToText speech = SpeechToText();

  Future<bool> initSpeech() async {
    //

    return await speech.initialize();
  }

  void set(String d){
    data = d;
    // print (d);
  }

  String get(){
    return data;
  }

// void print(String d){
//   print (d);
// }
}