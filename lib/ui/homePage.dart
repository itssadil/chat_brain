import 'package:chatbrain/ui/subUi/msgFromGpt.dart';
import 'package:chatbrain/widgets/waitingForMsg.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/msgListProvider.dart';
import 'subUi/msgTxtField.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Chat Brain"),
          centerTitle: true,
          actions: [
            Consumer<MsgListProvider>(
              builder: (context, myMsg, child) {
                return myMsg.myMsg.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          myMsg.clearMsgValue();
                          myMsg.isMeValue(false);
                        },
                        icon: Icon(Icons.replay),
                      )
                    : Center();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MsgFromGpt(),
              waitingForMsg(),
              TextFieldNdVoice(),
            ],
          ),
        ),
      ),
    );
  }
}
