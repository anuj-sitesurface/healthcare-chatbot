import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:sitesurface_flutter_openai/sitesurface_flutter_openai.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.red,
          brightness: Brightness.light),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _openAiClient = OpenAIClient(OpenAIConfig(
      apiKey: "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",
      organizationId: "org-kEuqxSzr78UwdBMNVwpJ5npp"));

  final _textEditingController = TextEditingController();
  final _scrollController = ScrollController();
  final _completionRequest =
      CreateCompletionRequest(model: "text-davinci-003", maxTokens: 2048);

  final healthCareField = "In the field of healthcare, ";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // the whole visible screen
      backgroundColor: Colors.white,
      appBar:
          AppBar(title: const Text("Health Chatbot")), // head section of screen
      body: ChatGPTBuilder(
        // this is what builds the UI if any prompts are given
        completionRequest: _completionRequest,
        openAIClient: _openAiClient,
        builder: (context, messages, onSend) {
          return Column(
            // It will render everything below onw another
            children: [
              const SizedBox(
                height: 10,
              ),
              Expanded(
                // it will expand the area
                child: ListView.separated(
                    itemCount: messages.length,
                    controller: _scrollController,
                    separatorBuilder: (context, index) => const SizedBox(
                          height: 5,
                        ),
                    itemBuilder: (context, index) {
                      var isSender = !messages[index].fromChatGPT;
                      var senderMessage = isSender
                          ? messages[index]
                              .message
                              .replaceAll(healthCareField, '')
                          : messages[index].message;
                      return BubbleSpecialThree(
                        isSender: isSender,
                        text: senderMessage[0].toUpperCase() +
                            senderMessage.substring(1),
                        color: isSender ? Colors.blueGrey : Colors.redAccent,
                        tail: true,
                        textStyle: TextStyle(
                            color: isSender ? Colors.white : Colors.white,
                            fontSize: 16),
                      );
                    }),
              ),
              Row(
                // textfield
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        controller: _textEditingController,
                        decoration: InputDecoration(
                            hintText: "Ask anything about healthcare",
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey),
                            enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(20)),
                            disabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(20)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(20)),
                            border: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(20))),
                      ),
                    ),
                  ),
                  FloatingActionButton(
                      onPressed: () {
                        if (_textEditingController.text.trim().isEmpty) return;
                        onSend(healthCareField + _textEditingController.text)
                            .whenComplete(() {
                          _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 100),
                              curve: Curves.bounceIn);
                        });
                        FocusScope.of(context).unfocus();
                        _textEditingController.clear();
                      },
                      child: const Icon(Icons.send)),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
