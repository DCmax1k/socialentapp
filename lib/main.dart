import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login.dart';
import 'pages/signup.dart';
import 'pages/home.dart';
import 'pages/admin.dart';
import 'pages/comments.dart';
import 'pages/account.dart';
import 'package:http/http.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return MaterialApp(
      routes: {
        '/': (context) => Loading(),
        '/index': (context) => IndexPage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => HomePage(),
        '/admin': (context) => AdminPage(),
        '/comments': (context) => Comments(),
        '/editprofile': (context) => EditProfileCont(),
      },
      initialRoute: '/',
    );
  }
}

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  String authToken = 'NoAuthToken';

  Map data = {};
  Map user = {};

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty
        ? data
        : ModalRoute.of(context)!.settings.arguments != null
            ? ModalRoute.of(context)!.settings.arguments as Map
            : {};
    user = data.isNotEmpty ? data['user'] : user;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'See what\'s happening on Socialent!',
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Patrick',
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              color: Color.fromRGBO(180, 221, 255, 1.0),
                              fontFamily: 'Patrick',
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue),
                            fixedSize:
                                MaterialStateProperty.all(Size(300.0, 35.0)),
                            shape: MaterialStateProperty.all(
                              StadiumBorder(),
                            ),
                          ),
                        ),
                        SizedBox(height: 5.0),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: Text(
                            'Log in',
                            style: TextStyle(
                              fontFamily: 'Patrick',
                            ),
                          ),
                          style: ButtonStyle(
                            fixedSize:
                                MaterialStateProperty.all(Size(300.0, 35.0)),
                            shape: MaterialStateProperty.all(
                              StadiumBorder(
                                side: BorderSide(color: Colors.blue, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Color.fromRGBO(180, 221, 255, 1.0),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Join',
                          style: TextStyle(
                            fontSize: 60.0,
                            fontFamily: 'Patrick',
                          ),
                        ),
                        Text(
                          'Socialent',
                          style: TextStyle(
                            fontSize: 60.0,
                            fontFamily: 'Patrick',
                          ),
                        ),
                        Text(
                          'Today!',
                          style: TextStyle(
                            fontSize: 60.0,
                            fontFamily: 'Patrick',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Transform.translate(
                          offset: Offset(0.0, 15.0),
                          child: Container(
                            child: Image(
                              image: AssetImage('assets/grouplogo.png'),
                              height: 200,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Loading extends StatefulWidget {
  Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  bool loadedUser = false;
  Map user = {};
  String currentRedirect = 'index';
  bool _visible = false;
  bool redirected = false;
  bool checkedLogin = false;
  List postsFollowing = [];
  bool startedLoading = false;

  void redirect(page) {
    if (redirected == false) {
      redirected = true;
      if (page == 'index') {
        Navigator.pushReplacementNamed(context, '/index', arguments: {});
      } else if (page == 'home')
        Navigator.pushReplacementNamed(context, '/home', arguments: {
          'user': user,
          'postsFollowing': postsFollowing,
        });
    }
  }

  void checkLogin() async {
    checkedLogin = true;
    print('checked login');
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token') ?? 'NoToken';
    if (authToken == 'NoToken') {
      loadedUser = true;
      redirect('index');
    } else {
      // Timer(Duration(seconds: 1000), () async {
      String postURL = 'https://www.socialentapp.com/home/getfromapp';
      Response response = await post(Uri.parse(postURL), body: {
        'auth_token': authToken,
      });
      if (response.body != 'Forbidden') {
        Map resJSON = jsonDecode(response.body);
        if (resJSON['user'] != null) {
          user = resJSON['user'];
          postsFollowing = resJSON['postsFollowing'];
          // get prefs
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('postsFollowing', jsonEncode(postsFollowing));
          await prefs.setString('user', jsonEncode(user));
          loadedUser = true;
          currentRedirect = 'home';
          redirect('home');
        } else {
          prefs.remove('auth_token');
          loadedUser = true;
          redirect('index');
        }
      } else {
        prefs.remove('auth_token');
        loadedUser = true;
        redirect('index');
      }

      // });
    }
  }

  void loadingScreen() async {
    if (startedLoading == false) {
      startedLoading = true;

      if (loadedUser) {
        redirect(currentRedirect);
      }
      Timer(Duration(milliseconds: 100), () {
        setState(() {
          _visible = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // clearPrefs();
    if (checkedLogin == false) {
      checkLogin();
    }
    loadingScreen();
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/SocialentIcon.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: Duration(seconds: 1),
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  bottom: 10,
                  left: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'Connecting',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        letterSpacing: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
