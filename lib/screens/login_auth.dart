import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertil/main.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login',
      home: LogIn(),
    );
  }
}

class LogIn extends StatefulWidget {
  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  TextEditingController controller = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log in'),
        elevation: 0.0,
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.menu), onPressed: () {}),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.search), onPressed: () {})
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(top: 50)),
              Center(
                child: Image(
                  image: AssetImage('image/munji.png'),
                  width: 170.0,
                ),
              ),
              Form(
                child: Theme(
                  data: ThemeData(
                      primaryColor: Colors.grey,
                      inputDecorationTheme: InputDecorationTheme(
                          labelStyle:
                          TextStyle(color: Colors.teal, fontSize: 15.0))),
                  child: Container(
                    padding: EdgeInsets.all(40.0),
                    child: Builder(builder: (context) {
                      return Column(
                        children: [
                          TextField(
                            controller: controller,
                            autofocus: true,
                            decoration:
                            InputDecoration(labelText: 'Enter email'),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          TextField(
                            controller: controller2,
                            decoration:
                            InputDecoration(labelText: 'Enter password'),
                            keyboardType: TextInputType.text,
                            obscureText: true,
                          ),
                          SizedBox(
                            height: 40.0,
                          ),
                          ButtonTheme(
                            minWidth: 100.0,
                            height: 50.0,
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  final UserCredential userCredential =
                                  await _auth.signInWithEmailAndPassword(
                                    email: controller.text,
                                    password: controller2.text,
                                  );
                                  final User? user =
                                      userCredential.user;
                                  if (user != null) {
                                    Navigator.pushReplacement( // Use pushReplacement to replace the login screen with the main screen
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) => MyHomePage(), // Navigate to the main screen
                                      ),
                                    );
                                  } else {
                                    showSnackBar(
                                      context,
                                      Text('로그인에 실패했습니다.'),
                                    );
                                  }
                                } catch (e) {
                                  print('Error:$e');
                                  showSnackBar(
                                    context,
                                    Text('로그인에 실패했습니다. 오류: $e'),
                                  );
                                }
                              },
                              child: Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 35.0,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showSnackBar(BuildContext context, Text text) {
  final snackBar = SnackBar(
    content: text,
    backgroundColor: Color.fromARGB(255, 112, 48, 48),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

class NextPage extends StatelessWidget {
  const NextPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Next Page'),
      ),
      body: Container(),
    );
  }
}
