import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';

class MicScreen extends StatefulWidget {
  @override
  _MicScreenState createState() => _MicScreenState();
}

class _MicScreenState extends State<MicScreen> {
  var textSpeech = "CLICK ON MIC TO RECORD";
  SpeechToText speechToText = SpeechToText();
  var isListening = false;
  String recordedText = "";

  @override
  void initState() {
    super.initState();
    checkMic();
    speechToText.errorListener = (error) {
      setState(() {
        textSpeech = "Error: ${error.errorMsg}";
        isListening = false;
      });
    };
  }

  void checkMic() async {
    bool micAvailable = await speechToText.initialize();
    if (!micAvailable) {
      print("Microphone access denied or unavailable");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mic Screen'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(textSpeech),
              GestureDetector(
                onTap: toggleListening,
                child: CircleAvatar(
                  child: isListening ? Icon(Icons.stop) : Icon(Icons.mic),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: stopListeningAndSendToPython,
                child: Text('Stop Listening and Send to Python'),
              ),
              SizedBox(height: 20),
              Text(recordedText),
            ],
          ),
        ),
      ),
    );
  }

  void toggleListening() {
    if (isListening) {
      stopListening();
    } else {
      startListening();
    }
  }

  void startListening() {
    setState(() {
      isListening = true;
      textSpeech = "Listening...";
    });

    speechToText.listen(
      listenFor: Duration(seconds: 20),
      onResult: (result) {
        setState(() {
          textSpeech = result.recognizedWords;
          recordedText = result.recognizedWords; // Store recognized text
        });
      },
    );
  }

  void stopListening() {
    if (isListening) {
      speechToText.stop();
      setState(() {
        isListening = false;
      });
    }
  }

  Future<void> stopListeningAndSendToPython() async {
    print('Recorded text: $recordedText');
    if (isListening) {
      stopListening();
      // Send the recorded text to Python
      await sendVoiceInputToPython(recordedText);
    }
  }

  Future<void> sendVoiceInputToPython(String voiceInput) async {
    print('Sending voice input to Python: $voiceInput');
    final url = Uri.parse('http://127.0.0.1:5000/process_voice_input');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'voiceInput': voiceInput}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final processedData = data['processedData'];
      print('Processed data from Python: $processedData');
      // Handle the processed data here
    } else {
      print(
          'Failed to send voice input to Python. Status code: ${response.statusCode}');
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: MicScreen(),
  ));
}
