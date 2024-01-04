library recaptchav2_plugin;

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RecaptchaV2 extends StatefulWidget {
  final String apiKey;
  final String pluginURL =
      "https://software-incubator.github.io/flutter_recaptcha/";
  final RecaptchaV2Controller controller;
  final ValueChanged<String> response;

  RecaptchaV2({
    Key? key,
    required this.apiKey,
    required this.controller,
    required this.response,
  })  : assert(apiKey.isNotEmpty, "Google ReCaptcha API KEY is missing."),
        super(key: key);

  @override
  State<RecaptchaV2> createState() => _RecaptchaV2State();
}

class _RecaptchaV2State extends State<RecaptchaV2> {
  late WebViewController webViewController;
  bool isControllerInitialized = false;

  void onListen() {
    if (widget.controller.visible && isControllerInitialized) {
      webViewController.clearCache();
      webViewController.reload();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(onListen);
  }

  @override
  void didUpdateWidget(RecaptchaV2 oldWidget) {
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(onListen);
      widget.controller.addListener(onListen);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.controller.removeListener(onListen);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'RecaptchaFlutterChannel',
        onMessageReceived: (receiver) {
          String _token = receiver.message;
          if (_token.contains("verify")) {
            _token = _token.substring(7);
          }
          widget.response(_token);
          widget.controller.hide();
        },
      )
      ..loadRequest(Uri.parse("${widget.pluginURL}?api_key=${widget.apiKey}"));
    isControllerInitialized = true;
    return widget.controller.visible && isControllerInitialized
        ? Stack(
            children: <Widget>[
              WebViewWidget(
                controller: webViewController,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    child: const Text("CANCEL RECAPTCHA"),
                    onPressed: widget.controller.hide,
                  ),
                ),
              ),
            ],
          )
        : Container(
            height: 100,
            width: 100,
            color: Colors.red,
          );
  }
}

class RecaptchaV2Controller with ChangeNotifier {
  bool _visible = false;

  bool get visible => _visible;

  void show() {
    _visible = true;
    notifyListeners();
  }

  void hide() {
    _visible = false;
    notifyListeners();
  }
}
