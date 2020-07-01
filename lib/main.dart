import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:signupfacebook/youtubepromotion.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign in with Facebook',
      theme: ThemeData(primarySwatch: Colors.indigo,),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  dynamic _userData;

  @override
  void initState() {
    super.initState();
    _checkIfIsLogged();
  }

  _checkIfIsLogged() async {
    final accessToken = await FacebookAuth.instance.isLogged;
    if (accessToken != null) {
      FacebookAuth.instance.getUserData().then((userData) {
        setState(() => _userData = userData);
      });
    }
  }

  _login() async {
    final result = await FacebookAuth.instance.login();
    switch (result.status) {
      case FacebookAuthLoginResponse.ok:
        final userData = await FacebookAuth.instance.getUserData();

        AuthCredential credential =  FacebookAuthProvider.getCredential(accessToken: result.accessToken.token);
        await FirebaseAuth.instance.signInWithCredential(credential);
        setState(() => _userData = userData);

        break;
      case FacebookAuthLoginResponse.cancelled:
        print("login cancelled");
        break;
      default:
        print("login failed");
        break;
    }
  }

  _logOut() async {
    await FacebookAuth.instance.logOut();
    setState(() => _userData = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign in with Facebook'),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _userData != null ?
          Column(
            children: <Widget>[
              Card(
                  child: Container(
                  width: 120,
                  height: 120,
                  color: Colors.grey,
                  child: Image.network(_userData['picture']['data']['url'],fit: BoxFit.fill,)
                ),
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                ),
                elevation: 5,
                margin: EdgeInsets.all(10),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Name: ${_userData['name']}\nEmail: ${_userData['email']}',style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),),
              )
            ],
          ) :
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("NO LOGGED \n\nPlease Touch the Facebook Log In Button",style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(12.0),
                ),
                padding: EdgeInsets.all(16),
                textColor: Colors.white,
                color: _userData != null ? Colors.black : Colors.blue[900],
                onPressed: () => _userData != null ? _logOut() : _login(),
                child: Text(_userData != null ? 'Log Out' : 'Facebook Log In', style: TextStyle(fontSize: 20),),
              ),
            ),
          ),
          youtubePromotion()
        ],
      ),
    );
  }
}
