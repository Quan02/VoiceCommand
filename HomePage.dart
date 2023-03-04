import 'package:chatagent/WhatSapp.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'dart:async';
import 'Email.dart';
import 'Phone.dart';
import 'SMS.dart';
import 'package:google_fonts/google_fonts.dart';
//This is the main page of app
//It contains each button to different page
//setting and start recording button

//use to pop back code
//Navigator.pop(context, result);

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  //variable that determined which function will be invoked
  //_goEmail true, then go to Email function
  //bool _goEmail = false;

  //duration for function page to exists
  int _durationpage = 30;
  int _minpage = 10;
  int _maxpage= 60;

  //for change the Color of border
  Color sendEmailColor = Colors.blue.withOpacity(0.3);
  Color phoneCallColor = Colors.blue.withOpacity(0.3);
  Color whatsappColor = Colors.blue.withOpacity(0.3);
  Color sendSmsColor = Colors.blue.withOpacity(0.3);

  //create instance of SpeechToText
  final SpeechToText speech = SpeechToText();
  //SpeechToText speech = SpeechToText();

  //_speech Enabled control whether app is listening
  //if speechEnabled true, mean currently app is listening to user
  bool _speechEnabled = false;

  //variable control microphone to keep working
  bool _keepListening = true;

  //confirmation state, 0 mean no function is known
  //1 mean ask for confirmation 2 means go to function page
  int confirm = 0;

  //_translatedWords record the translated words
  String _translatedWords = '';

  //Question that ask user to answer
  String _question = 'Hi, How Can I Help You?';

  String instructions = 'Tap the microphone for listening，\n\nTap again for us to process your words\n\nTo resaid word, pls wait for a while without tap button';

  //timeListen is time for user to listen
  Duration timeListen = Duration(seconds: 100);
  //timeListen is maximum time for user to pause between words
  Duration timePaused = Duration(seconds: 10);

  //do a timeline for the listening process
  late AnimationController controller;

  @override
  void initState() {
    // TODO: implement initState
    _startListening();
    super.initState();
    _initSpeech();
    _initController();
    _keepListening = true;
  }



  /*@override
  void dispose() {
    speech.cancel();
    super.dispose();
  }*/


  void _initController() async{
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: Duration(seconds: 5),

    )..addListener(() {
      setState(() {});
    });
    controller.stop(canceled: true);
  }

  //function to initialize the app
  void _initSpeech() async {
    //
    _speechEnabled = await speech.initialize();
    setState(() {});
  }

  //call while each time start a speech recognition
  void _startListening() async{
    //await speech.listen()
    while(_keepListening)
      {
        await speech.listen(onResult: _onSpeechResult,listenFor: timeListen, pauseFor: timePaused );
        //print('$_translatedWords');
        _checkFunction(userSaid: _translatedWords);


      }
    setState(() {});
  }

  //stop the speech recognition after timeout
  void _stopListening() async{
    print('have stop');


    await speech.stop();
    setState(() {});
  }

  void _updateDuration(int newValue)
  {
    setState(() {
      _durationpage = newValue;
    });
  }



  void _onSpeechResult(SpeechRecognitionResult result)
  {
    setState(() {
      _translatedWords = result.recognizedWords;
      //_checkFunction(userSaid: _translatedWords);
      //print(_translatedWords);
    });
  }

  //function to adjust the _duration on each page
  void _onLineDrag(DragUpdateDetails details)
  {
    setState(() {
      _durationpage += details.delta.dx~/3;
      //user can adjust from 10 seconds to 60seconds
      _durationpage = _durationpage.clamp(_minpage, _maxpage);
    });
  }

  ThemeData _theme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    accentColor: Colors.yellow,

    fontFamily: 'Montserrat',
    textTheme: TextTheme(
      headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
      bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Roboto'),
    ),
  );

  /*Future DurationChanged() async
  {
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: Duration(seconds: 5),
    )..addListener(() {
      setState(() {});
    });
    controller.repeat(reverse: false,);
    setState(() {
    });
  }*/


  @override
  Widget build(BuildContext context) {
    final double percentage = (_durationpage - _minpage)/(_maxpage-_minpage);
    final leftColor = Colors.red;
    final rightColor = Colors.blue;
    final color = Color.lerp(leftColor, rightColor, percentage);


    return Scaffold(
      appBar: AppBar(
        title: Text('Demo'),
      ),
      body: Center(
        child: Column(
          //let all elements focus on middle
          //can change due to needs
          mainAxisAlignment: MainAxisAlignment.center,

          children: <Widget>[
            Container(
              height: 5,
            ),
            Container(
              width: 250,
              height: 50,
              child: Slider(
                value: _durationpage.toDouble(),
                min: 10,
                max: 60,
                onChanged: (double newValue)
                {
                  setState(() {
                    _durationpage = newValue.round();
                  });
                },
              ),
            ),
            Container(
              child: Text('Duration on each page : $_durationpage', style: TextStyle(
                fontSize: 16.0,
              ),),

            ),
            SingleChildScrollView(
              child: Container(
                width: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // add this line to wrap the column content
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      width: 200,
                      height: 100,
                      child: Text(
                        'Function List',
                        style: GoogleFonts.openSans(

                          textStyle: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,

                          decoration: TextDecoration.underline,
                        ),
                        )
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(5.0),
                      margin: EdgeInsets.all(5),
                      width: 200,
                      height: 60,
                        decoration: BoxDecoration(
                        color: sendEmailColor,
                        border: Border.all(
                          color: Colors.blue,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Send Email',
                            style: GoogleFonts.openSans(

                              textStyle: TextStyle(
                                fontSize: 16.0,

                              ),
                            )
                        ),
                      ),
                    ),
                    //
                    /*(
                      height: 5,
                    ),*/
                    Container(
                      padding: EdgeInsets.all(5.0),
                      margin: EdgeInsets.all(5),
                      width: 200,
                      height: 60,
                      decoration: BoxDecoration(
                        color: phoneCallColor,
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Phone Call',
                            style: GoogleFonts.openSans(

                              textStyle: TextStyle(
                                fontSize: 16.0,

                              ),
                            )
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(5.0),
                      margin: EdgeInsets.all(5),
                      width: 200,
                      height: 60,
                      decoration: BoxDecoration(
                        color: whatsappColor,
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Send WhatSapp',
                            style: GoogleFonts.openSans(

                              textStyle: TextStyle(
                                fontSize: 16.0,

                              ),
                            )
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(5.0),
                      margin: EdgeInsets.all(5),
                      width: 200,
                      height: 60,
                      decoration: BoxDecoration(
                        color: sendSmsColor,
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Send SMS',
                            style: GoogleFonts.openSans(

                              textStyle: TextStyle(
                                fontSize: 16.0,

                              ),
                            )
                        ),
                      ),
                    ),
                    Container(
                      height: 10,
                    )
                  ],
                ),
              ),
            ),

            /*Container(
              width: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    width: 200,
                    height: 100,

                    child: Text(
                      'Function List',
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    width: 200,
                    height: 80,
                    decoration: BoxDecoration(
                      color: sendEmailColor,
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      'Send Email',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    width: 200,
                    height: 80,
                    decoration: BoxDecoration(
                      color: phoneCallColor,
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      'Phone Call',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    width: 200,
                    height: 80,
                    decoration: BoxDecoration(
                      color: whatsappColor,
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Text(
                        'Send WhatSapp',
                      style: TextStyle(
                      fontSize: 20,
                    ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    width: 200,
                    height: 80,
                    decoration: BoxDecoration(
                      color: sendSmsColor,
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      'Send SMS',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),*/
            Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Text(
                      // string tell user what to do
                      // change due to what user ask
                      '$_question',
                      // change text attributes
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),

                    ),
                    Container(
                      height: 80,
                    ),
                    Text(
                      _translatedWords,
                    ),
                  ],
                ),
              ),
            Container(
              padding: EdgeInsets.all(10),
              // a button to control if the phone is listening or not
              child: FloatingActionButton(
                onPressed:

                speech.isNotListening?_startListening:  _stopListening,
                  //If not yet listening then speech start, otherwise stop


                tooltip: 'Listen',
                child: Icon(speech.isNotListening? Icons.mic_off : Icons.mic),

              ),
            ),
            /*LinearProgressIndicator(
              value: controller.value,
              semanticsLabel: 'Linear progress Indicator',
           ), */
          ],
        ),
      ),

    );
  }

  Future _changeBorder({required String text}) async
  {
    if(text == 'send email')
      {
        //change the color of send email border
        if(confirm == 1)
          {
            sendEmailColor = Colors.red.withOpacity(0.3);
          }
      }
    if(text == 'phone')
      {
        if(confirm == 1)
        {
          phoneCallColor = Colors.red.withOpacity(0.3);
        }
      }
    if(text == 'whatsapp')
    {
      if(confirm == 1)
      {
        whatsappColor = Colors.red.withOpacity(0.3);
      }
    }
    if(text == 'sms')
    {
      if(confirm == 1)
      {
        sendSmsColor = Colors.red.withOpacity(0.3);
      }
    }
    if(text == 'No' || text =='Yes')
      {
        sendEmailColor = phoneCallColor = whatsappColor =sendSmsColor = Colors.blue.withOpacity(0.3);
      }
    setState(() => null);
  }

  //check which function need to be run
  Future _changeQuestion() async
  {
    if(confirm == 1)
      {
        _question ='Are you sure you want this function ? ';

      }
    else if(confirm == 0)
      {
        _question =  'Hi, How Can I Help You?';
      }
    setState(() => null);
  }


  //check which function need to be run
  Future _checkFunction({required String userSaid}) async
  {
    if(confirm == 0)
    {
      if(userSaid.toLowerCase().contains('send email') || userSaid.toLowerCase().contains('sent email'))
      {
        confirm += 1;
        //change the border color
        _changeBorder(text: 'send email');
        _changeQuestion();
        _translatedWords = '';
      }
      else if(userSaid.toLowerCase().contains('phone') )
        {
          confirm += 1;
          //change the border color
          _changeBorder(text: 'phone');
          _changeQuestion();
          _translatedWords = '';
        }
      else if(userSaid.toLowerCase().contains('whatsapp') )
      {
        confirm += 1;
        //change the border color
        _changeBorder(text: 'whatsapp');
        _changeQuestion();
        _translatedWords = '';
      }
      else if(userSaid.toLowerCase().contains('send sms') )
      {
        confirm += 1;
        //change the border color
        _changeBorder(text: 'sms');
        _changeQuestion();
        _translatedWords = '';
      }
    }else if(confirm == 1)
      {
        if(userSaid.toLowerCase().contains('yes') )
          {
            if(sendEmailColor == Colors.red.withOpacity(0.3))
              {
                confirm = 0;
                _changeQuestion();
                _changeBorder(text: 'No');
                _translatedWords = '';
                //_keepListening = false;
                setState(() {
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmailFunction(speech:speech,durationpage: _durationpage)),
                );

// Pop back to MainPage after 30 seconds
                Future.delayed(Duration(seconds: _durationpage)).then((value) {
                  setState(() {
                    // Update the state of the current widget
                  });
                  Navigator.pop(context);
                });
              }else if(phoneCallColor == Colors.red.withOpacity(0.3))
                {
                  confirm = 0;
                  _changeQuestion();
                  _changeBorder(text: 'No');
                  _translatedWords = '';
                  _keepListening = false;
                  setState(() {
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>PhonePage(speech:speech,durationpage :_durationpage)),
                  );

                    // Pop back to MainPage after 30 seconds
                  Future.delayed(Duration(seconds: _durationpage)).then((value) {
                    // Initialization logic
                    initState();
                    Navigator.pop(context);
                  });
                }else if(whatsappColor == Colors.red.withOpacity(0.3))
                  {
                    confirm = 0;
                    _changeQuestion();
                    _changeBorder(text: 'No');
                    _translatedWords = '';
                    _keepListening = false;
                    setState(() {
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>WhatSapp(speech:speech,durationpage :_durationpage)),
                    );

                    // Pop back to MainPage after 30 seconds
                    Future.delayed(Duration(seconds: _durationpage)).then((value) {
                      // Initialization logic
                      initState();
                      Navigator.pop(context);
                    });
                  }else if(sendSmsColor == Colors.red.withOpacity(0.3))
                  {
                    confirm = 0;
                    _changeQuestion();
                    _changeBorder(text: 'No');
                    _translatedWords = '';
                    //_keepListening = false;
                    setState(() {
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>SendSMS(speech:speech,durationpage :_durationpage)),
                    );
                    // Pop back to MainPage after 30 seconds
                    Future.delayed(Duration(seconds: _durationpage)).then((value) {
                      _stopListening();
                      Navigator.pop(context);

                    });
                  }

          }
        else if(userSaid.toLowerCase().contains('no') )
          {
            confirm = 0;
            _changeQuestion();
            _changeBorder(text: 'No');
            _translatedWords = '';
          }
      }
  }
  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
  }
}


