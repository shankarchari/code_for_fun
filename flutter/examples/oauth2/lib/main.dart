import 'dart:async';
import 'dart:convert' as Convert;

import 'package:flutter/material.dart';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:http/http.dart' as http;

import './config.dart';
import './jwt.dart';

import 'package:corsac_jwt/corsac_jwt.dart';

const kAndroidUserAgent =
    'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';

String selectedUrl = 'https://flutter.io';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final flutterWebviewPlugin = FlutterWebviewPlugin();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web View Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: _getRouteSettings(),
    );
  }

  _getRouteSettings() {
    return {
      '/': (_) => MyHomePage(title: 'Flutter Web View Demo'),
      '/widget': (_) {
        return WebviewScaffold(
          url: selectedUrl,
          withZoom: true,
          userAgent: kAndroidUserAgent,
          clearCache: true,
          clearCookies: true,
          // appBar: AppBar(
          //   title: const Text('Widget Web View'),
          // ),
          // withZoom: true,
          // withLocalStorage: true,
          // hidden: true,
          // initialChild: Container(
          //   color: Colors.redAccent,
          //   child: const Center(
          //     child: Text('Waiting...'),
          //   ),
          // ),
          // bottomNavigationBar: BottomAppBar(
          //   child: Row(
          //     children: <Widget>[
          //       IconButton(
          //         icon: const Icon(Icons.arrow_back_ios),
          //         onPressed: () {
          //           flutterWebviewPlugin.goBack();
          //         },
          //       ),
          //       IconButton(
          //         icon: Icon(Icons.arrow_forward_ios),
          //         onPressed: () {
          //           flutterWebviewPlugin.goForward();
          //         },
          //       ),
          //       IconButton(
          //         icon: Icon(Icons.autorenew),
          //         onPressed: () {
          //           flutterWebviewPlugin.reload();
          //         },
          //       ),
          //     ],
          //   ),
          // ),
        );
      }
    };
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final flutterWebviewPlugin = FlutterWebviewPlugin();
  StreamSubscription _onDestroy;
  StreamSubscription<String> _onUrlChanged;

  StreamSubscription<WebViewStateChanged> _onStateChanged;
  StreamSubscription<WebViewHttpError> _onHttpError;
  StreamSubscription<double> _onScrollYChanged;
  StreamSubscription<double> _onScrollXChanged;

  final _urlCtrl = TextEditingController(text: selectedUrl);
  final _codeCtrl = TextEditingController(text: 'window.navigator.userAgent');
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _history = [];

  @override
  void initState() {
    super.initState();

    flutterWebviewPlugin.close();

    _urlCtrl.addListener(() {
      selectedUrl = _urlCtrl.text;
    });

    _onDestroy = flutterWebviewPlugin.onDestroy.listen((_) {
      if (mounted) {
        _scaffoldKey.currentState.showSnackBar(
          const SnackBar(
            content: const Text('Web View Destroyed'),
          ),
        );
      }
    });

    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) {
      flutterWebviewPlugin.getCookies().then<Map<String, String>>((response) {
        print(response);
      });
      if (mounted) {
        setState(() {
          _history.add('onUrlChanged: $url');
          if (url.startsWith(CONFIGURATIONS.ivyEndPoint + 'manufacturers')) {}
          if (url.startsWith(CONFIGURATIONS.redirectUri)) {
            String code = (Uri.parse(url).queryParameters.values.toList()[0]);
            debugPrint(code);
            print(url);
            selectedUrl = code;
            flutterWebviewPlugin.close();
            Navigator.of(context).pushNamed('/');
          }
        });
      }
    });

    _onScrollYChanged =
        flutterWebviewPlugin.onScrollYChanged.listen((double y) {
      if (mounted) {
        setState(() {
          _history.add('Scroll in Y Direction: $y');
        });
      }
    });

    _onScrollXChanged =
        flutterWebviewPlugin.onScrollXChanged.listen((double x) {
      if (mounted) {
        setState(() {
          _history.add('Scroll in X Direction: $x');
        });
      }
    });

    _onStateChanged =
        flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      if (mounted) {
        setState(() {
          _history.add('onStateChanged: ${state.type} ${state.url}');
        });
      }
    });

    _onHttpError =
        flutterWebviewPlugin.onHttpError.listen((WebViewHttpError error) {
      if (mounted) {
        setState(() {
          _history.add('onHttpError: ${error.code} ${error.url}');
        });
      }
    });
  }

  @override
  void dispose() {
    _onDestroy.cancel();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    _onHttpError.cancel();
    _onScrollXChanged.cancel();
    _onScrollYChanged.cancel();

    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(24.0),
              child: TextField(
                controller: _urlCtrl,
              ),
            ),
            RaisedButton(
              onPressed: () {
                flutterWebviewPlugin.launch(selectedUrl,
                    rect: Rect.fromLTWH(
                        0.0, 0.0, MediaQuery.of(context).size.width, 300.0),
                    userAgent: kAndroidUserAgent);
              },
              child: const Text('Open Web View (rect)'),
            ),
            RaisedButton(
              onPressed: () {
                flutterWebviewPlugin.launch(selectedUrl, hidden: true);
              },
              child: const Text('Open "hidden" Web View'),
            ),
            RaisedButton(
              onPressed: () {
                flutterWebviewPlugin.launch(selectedUrl);
              },
              child: const Text('Open Fullscreen Webview'),
            ),
            RaisedButton(
              onPressed: () {
                selectedUrl = 'https://github.com';
                Navigator.of(context).pushNamed('/widget').then((response) {
                  print(response);
                });
              },
              child: const Text('Open widget webview'),
            ),
            RaisedButton(
              onPressed: () {
                Map<String, String> queryParams = {
                  'client_id': CONFIGURATIONS.googleAppId,
                  'redirect_uri': CONFIGURATIONS.redirectUri,
                  'response_type': 'code',
                  'scope': 'email'
                };

                String uri = Uri.https(
                  'accounts.google.com',
                  '/o/oauth2/v2/auth',
                  queryParams,
                ).toString();
                selectedUrl = uri;
                Navigator.of(context).pushNamed('/widget').then((response) {
                  //print(response);
                });
              },
              child: const Text('Ivy Sign In'),
            ),
            RaisedButton(
              onPressed: () {
                String uri = Uri.https(
                  'www.googleapis.com',
                  '/oauth2/v4/token',
                ).toString();

                final payload = {
                  'code': selectedUrl,
                  'client_id': CONFIGURATIONS.googleAppId,
                  'client_secret': CONFIGURATIONS.googleSecret,
                  'redirect_uri': CONFIGURATIONS.redirectUri,
                  'grant_type': 'authorization_code',
                };

                final headers = {
                  'Content-Type': 'application/x-www-form-urlencoded'
                };

                http
                    .post(uri, body: payload, headers: headers)
                    .then((http.Response response) {
                  final formattedResponse = Convert.json.decode(response.body);
                  print(formattedResponse);
                  final String access_token = formattedResponse['access_token'];
                  http.get(
                      'https://www.googleapis.com/oauth2/v1/userinfo?alt=json',
                      headers: {
                        'Authorization': 'Bearer $access_token'
                      }).then((http.Response response) {
                    print(response.statusCode.toString());
                    var decodedResponse = Convert.json.decode(response.body);
                    print('DECODED RESPONSE - USER INFO');
                    print(decodedResponse);
                    JWTToken jwtToken = JWTToken();
                    String email = decodedResponse['email'];
                    String token = jwtToken.sign({'email': email});
                    print(token);
                    http
                        .get(CONFIGURATIONS.ivyEndPoint +
                            '/auth/local/verify-oauth2?token=$token&email=$email')
                        .then((http.Response ivResponse) {
                          print('IVY RESPONSE');
                          print(ivResponse.body);
                          print(ivResponse.statusCode);
                          var decodedIvyRes = Convert.json.decode(ivResponse.body);
                          var token = decodedIvyRes['token'];
                      print(token);
                      http.get(CONFIGURATIONS.ivyEndPoint + '/api/manufacturers', headers: {
                        'Authorization': 'Bearer $token'
                      }).then((http.Response response) {
                        var manufacturerRes = Convert.json.decode(response.body);
                        print(manufacturerRes);
                      });
                    });
                  });
                  //print(formattedResponse);
                });
              },
              child: Text('Get Access Token'),
            ),
            Container(
              padding: const EdgeInsets.all(24.0),
              child: TextField(
                controller: _codeCtrl,
              ),
            ),
            RaisedButton(
              child: const Text('Close'),
              onPressed: () {
                setState(() {
                  _history.clear();
                });
                flutterWebviewPlugin.close();
              },
            ),
            RaisedButton(
              onPressed: () {
                flutterWebviewPlugin.getCookies().then((m) {
                  setState(() {
                    _history.add('cookies: $m');
                  });
                });
              },
              child: const Text('Cookies'),
            ),
            RaisedButton(
              onPressed: () {
                JWTToken jwtToken = JWTToken();
                String token =
                    jwtToken.sign({'email': 'gowrishankar.m@ivymobility.com'});
                print(token);
                jwtToken.verify(
                    token, JWTHmacSha256Signer(CONFIGURATIONS.googleSecret));
              },
              child: const Text('JWT Tokens'),
            ),
            Text(_history.join('\n'))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
