import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../providers/msgListProvider.dart';
import '../../providers/speechToTextProvider.dart';
import '../../providers/visibleTextFieldProvider.dart';
import '../../widgets/msgSubmit.dart';

class TextFieldNdVoice extends StatelessWidget {
  const TextFieldNdVoice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController _myMsgController = TextEditingController();
    SpeechToText speechToText = SpeechToText();

    void submitMsg(String text) {
      var chatMsgProvider =
          Provider.of<MsgListProvider>(context, listen: false);
      chatMsgProvider.addMsgValue(
          FirebaseAuth.instance.currentUser!.uid, text, true);
      MsgSubmit.sendMsgToChatGPT(text, context);
      _myMsgController.clear();
    }

    return Column(
      children: [
        Consumer<VisibleTextField>(
          builder: (context, isTextField, child) {
            return Visibility(
              visible: isTextField.isTextField,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _myMsgController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          contentPadding: EdgeInsets.all(10),
                          labelText: "Send a message",
                          hintText: "Message...",
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.send,
                              size: 20,
                            ),
                            onPressed: () {
                              if (_myMsgController.text != "")
                                submitMsg(_myMsgController.text);
                            },
                          ),
                        ),
                        // onSubmitted: (value) => myMsg.addMsgValue(value),
                      ),
                    ),
                    SizedBox(width: 5),
                    CircleAvatar(
                      child: GestureDetector(
                        child: Icon(Icons.mic),
                        onTap: () async {
                          isTextField.isTextFieldValue(false);
                          var LongPressPro = Provider.of<SpeachToTextProvider>(
                              context,
                              listen: false);
                          LongPressPro.isListeningValue(true);
                          var available = await speechToText.initialize();
                          if (available) {
                            speechToText.listen(onResult: (result) {
                              LongPressPro.changeRecordText(
                                  result.recognizedWords);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Consumer<VisibleTextField>(
          builder: (context, isTextField, child) {
            return Visibility(
              visible: !isTextField.isTextField,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.25,
                decoration: BoxDecoration(
                  color: Colors.tealAccent,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 4,
                      blurRadius: 10,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Consumer<SpeachToTextProvider>(
                      builder: (context, isListening, child) {
                        return Text(
                          isListening.recordText == ""
                              ? "I'm listening..."
                              : isListening.recordText,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        isTextField.isTextFieldValue(true);
                        var LongPressPro = Provider.of<SpeachToTextProvider>(
                            context,
                            listen: false);
                        if (LongPressPro.recordText != "")
                          submitMsg(LongPressPro.recordText);
                        LongPressPro.isListeningValue(false);
                        LongPressPro.changeRecordText("");
                        speechToText.cancel();
                      },
                      child: Stack(
                        children: [
                          SpinKitDoubleBounce(
                            color: Colors.black,
                            size: 40.0,
                          ),
                          SpinKitSpinningLines(
                            color: Colors.tealAccent,
                            size: 40.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
