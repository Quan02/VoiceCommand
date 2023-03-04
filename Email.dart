import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:url_launcher/url_launcher.dart';
//This page helps to do email function
//Send email requires three input, which are emailSend, Subject and Body

class EmailFunction extends StatefulWidget {
  final int durationpage;
  final SpeechToText speech;
  const EmailFunction({Key? key, required this.durationpage,   required this.speech}) : super(key: key);

  @override
  State<EmailFunction> createState() => _EmailPage();
}

class _EmailPage extends State<EmailFunction> with SingleTickerProviderStateMixin {

  //initialize for animatioController
  late AnimationController _animationController;
  bool _isDisposed = false;
  //create situation of the app
  int _situation = 0;
  String _question = 'Please tell me the email address';
  String _confirmation = '';
  String _answer = '';

  //create data that may get from user
  //_emailSend is the email that receive the email
  String _emailSend = '';

  //_subject is the subject for the email sent
  String _subject = '';

  //_body is the body for the email sent
  String _body = '';

  //variable control microphone to keep working
  bool _keepListening = true;


  //create instance of SpeechToText for emailRecord
  //SpeechToText _emailReply = new SpeechToText();

  //_speech Enabled control whether app is listening
  //if speechEnabled true, mean currently app is listening to user
  bool _speechEnabled = false;


  String _userReply = '';



  //timeListen is time for user to listen
  Duration timeListen = Duration(seconds: 100);

  //timeListen is maximum time for user to pause between words
  Duration timePaused = Duration(seconds: 60);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initController();
    _initSpeech();
    _startListening();
  }

  void _initController() async {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationpage),
    )..addListener(() {
      if (!_isDisposed) {
        setState(() {});
      }
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _animationController.dispose();

    super.dispose();
  }

  //function to initialize the app
  void _initSpeech() async {
    _speechEnabled = await widget.speech.initialize();
    setState(() {});
  }

  //call while each time start a speech recognition
  void _startListening() async {
    //await _speechToText.listen()
    while (_keepListening) {

      await widget.speech.listen(onResult: _onSpeechResult, listenFor: timeListen, pauseFor: timePaused);
      _checkAnswer(userSaid: _userReply);
      print(_userReply);
    }
    setState(() {});
  }

  //stop the speech recognition after timeout
  void _stopListening() async {
    await widget.speech.stop();
    setState(() {});
  }


  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _userReply = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue.withOpacity(0.8),
        accentColor: Colors.yellow,

        fontFamily: 'Montserrat',
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 46.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Send Email'),
        ),
        body: Center(
          child: Column(
            //let all elements focus on middle
            //can change due to needs
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20),
                child: Text(
                  _question,
                    style: GoogleFonts.openSans(

                      textStyle: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                ),
              ),
              //add space between question and answer
              Container(
                height: 10,
              ),
              LinearProgressIndicator(
                value: _animationController.value,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              Container(
                padding: EdgeInsets.all(20),
                height: 10,
              ),
              Text(
                  _answer,
                  style: GoogleFonts.openSans(

                    textStyle: TextStyle(
                      fontSize: 20.0,

                    ),
                  ),
              ),
              Container(
                height: 10,
              ),
              Text(
                  _confirmation,
                  style: GoogleFonts.openSans(

                    textStyle: TextStyle(
                      fontSize: 20.0,

                    ),
                  ),
              ),
              //add space between question and answer
              Container(
                padding: EdgeInsets.all(20),
                height: 20,
              ),
              Text(
                _userReply,
                  style: GoogleFonts.openSans(

                    textStyle: TextStyle(
                      fontSize: 20.0,

                    ),
                  ),
              ),

              Container(
                  padding: EdgeInsets.all(10),
                  // a button to control if the phone is listening or not
                  child: FloatingActionButton(
                    onPressed:

                    widget.speech.isNotListening ? _startListening : _stopListening,
                    //If not yet listening then speech start, otherwise stop


                    tooltip: 'Listen',
                    child: Icon(
                        widget.speech.isNotListening ? Icons.mic_off : Icons.mic),

                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }




  //check answer need to be run
  Future _checkAnswer({required String userSaid}) async
  {
    if (_situation == 0 && userSaid.contains('.com')) {
      int amphora = _userReply.lastIndexOf(' ');
      _answer = (_userReply.substring(0, amphora) + '@' + _userReply.substring(amphora + 1)).replaceAll(' ', '');
      _confirmation = 'Is this the correct email address?';
      _situation += 1;
      _userReply = '';//situation = 1
      print('0');

    } else if (_situation == 1) {
      print('1');
      if (_userReply.toLowerCase().contains('yes') ) {
        _situation += 1;
        _question = 'Please tell me the subject';
        _emailSend = _answer;
        _answer = '';
        _confirmation = '';
        _userReply = '';
      } else if (_userReply.toLowerCase().contains('no')) {
        _situation -= 1;
        _answer = '';
        _confirmation = '';
        _userReply = '';
      }
    } else if (_situation == 2 && (_userReply.contains('done') || _userReply.contains('ok'))) {
      
      _answer = _userReply.replaceAll('done', '');
      _answer = _userReply.replaceAll('ok', '');
      _subject = _answer;
      _confirmation = 'Is this the correct subject?';
      _situation += 1;
      _userReply = '';
      print('2');

    } else if (_situation == 3) {
      print('3');

      if (_userReply.toLowerCase().contains('yes')) {
        _situation += 1;
        _question = 'Please tell me the body';
        _answer = '';
        _confirmation = '';
        _userReply = '';
      } else if (_userReply.toLowerCase().contains('no')) {
        _situation -= 1;
        _answer = '';
        _confirmation = '';
        _subject = '';
        _userReply = '';
      }
    } else if (_situation == 4 && (_userReply.contains('done') || _userReply.contains('ok')))  {
      print('4');
      _answer = _userReply.replaceAll('done', '');
      _answer = _userReply.replaceAll('ok', '');
      _body = _answer;
      _confirmation = 'Is this the correct body?';
      _situation += 1;
      _userReply = '';
    } else if (_situation == 5) {
      print('5');
      if (_userReply.toLowerCase().contains('yes')) {
        _situation += 1;
        _question = '';
        _answer = '';
        _confirmation = '';
        _userReply = '';
        _sendEmail(email: _emailSend, subject: _subject, body: _body);
        Navigator.pop(context);
      } else if (_userReply.toLowerCase().contains('no')) {
        _situation -= 1;
        _answer = '';
        _confirmation = '';
        _userReply = '';
      }
    }
    if(mounted)
      setState(() {

      });
  }

}




//Function that use to send email
Future _sendEmail({required String email, required String subject, required String body}) async
{
  final Email amail = Email(
    body: body,
    subject: subject,
    recipients: [email],
  );
  await FlutterEmailSender.send(amail);
}


