import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:owlbot_dart/owlbot_dart.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  String definition = '';
  String imageUrl = '';
  String example = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    setState(() {
      _lastWords = '';
      definition = '';
      imageUrl = '';
      example = '';
    });
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
    owlBotowlbot(_lastWords);
  }

  owlBotowlbot(lastWords) async {
    final OwlBot owlBot =
        OwlBot(token: "ddf48ab8e7429fcaa67dde1fe9c89c6b29675627");
    final OwlBotResponse? res = await owlBot.define(word: lastWords);
    for (var def in res!.definitions!) {
      setState(() {
        if (def.imageUrl != null) {
          imageUrl = def.imageUrl!;
        } else {
          imageUrl = "Empty";
        }
      });

      setState(() {
        if (def.example != null) {
          example = def.example!;
        } else {
          example = "";
        }
      });

      setState(() {
        if (def.definition != null) {
          definition = def.definition!;
        } else {
          definition = "";
        }
      });
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search search'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _speechToText.isListening
                        ? _lastWords
                        : _speechEnabled
                            ? 'Tap the microphone to start listening...'
                            : 'Speech not available',
                  ),
                  IconButton(
                      onPressed: _speechToText.isNotListening
                          ? _startListening
                          : _stopListening,
                      icon: Icon(_speechToText.isNotListening
                          ? Icons.mic_off
                          : Icons.mic))
                ],
              ),
            ),
            _lastWords == null || example == ""
                ? const SizedBox.shrink()
                : Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "Word:$_lastWords",
                      style: const TextStyle(fontSize: 20.0),
                    ),
                  ),
            definition == null || example == ""
                ? const SizedBox.shrink()
                : Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "Definition:$definition",
                      style: const TextStyle(fontSize: 20.0),
                    ),
                  ),
            example == null || example == ""
                ? const SizedBox.shrink()
                : Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "Example :$example",
                      style: const TextStyle(fontSize: 20.0),
                    ),
                  ),
            imageUrl == ""
                ? const SizedBox.shrink()
                : imageUrl == "Empty"
                    ? Image.asset('assets/image_not_found.png')
                    : Image.network(imageUrl),
          ],
        ),
      ),
    );
  }
}
