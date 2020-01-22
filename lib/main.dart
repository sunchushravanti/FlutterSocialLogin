import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'dart:convert' as JSON;
import 'package:http/http.dart' as http;
import 'package:flutter_twitter_login/flutter_twitter_login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
 //Signin with Google
  bool isGoogleLoggedIn=false;
  GoogleSignIn _googleSignIn = new GoogleSignIn(scopes: ['email']);

  //Signin with Facebook
  bool isFacebookLoggedIn=false;
  Map userProfile;
  final facebookLogin = FacebookLogin();

  //SIgnin with twitter
  FirebaseAuth _auth= FirebaseAuth.instance;
  FirebaseUser _user;
  bool isTwitterLoggedIn=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
              isGoogleLoggedIn?
              Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.network(
                  _googleSignIn.currentUser.photoUrl,
                  height:50.0,
                  width: 50.0,
                ),
                Text(_googleSignIn.currentUser.displayName),
                Text(_googleSignIn.currentUser.email),
                OutlineButton(
                  child: Text("Logout",style: TextStyle(fontFamily: 'Roboto',fontSize: 12,fontStyle: FontStyle.italic)),
                  onPressed: (){
                    logout_google();
                  },
                ),

              ]
           )
            :OutlineButton(
             child: Text("Login using Google",style: TextStyle(fontFamily: 'Roboto',fontSize: 12,fontStyle: FontStyle.italic)),
             onPressed: (){
                  login_google();
                },
              ),

                isFacebookLoggedIn?
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.network(userProfile["picture"]["data"]["url"], height: 50.0, width: 50.0,),
                      Text(userProfile["name"]),
                      OutlineButton(
                        child: Text("Logout",style: TextStyle(fontFamily: 'Roboto',fontSize: 12,fontStyle: FontStyle.italic)),
                        onPressed: (){
                          logout_facebook();
                        },
                      )
                    ]
                )
                :OutlineButton(
                  child: Text("Login using Facebook",style: TextStyle(fontFamily: 'Roboto',fontSize: 12,fontStyle: FontStyle.italic)),
                  onPressed: (){
                    login_facebook();
                  },
                ),

                isTwitterLoggedIn?
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.network(_user.photoUrl, height: 50.0, width: 50.0,),
                      Text("UserName: ${_user.displayName}"),
                      Text("Email: ${_user.email}"),
                      OutlineButton(
                        child: Text("Logout",style: TextStyle(fontFamily: 'Roboto',fontSize: 12,fontStyle: FontStyle.italic)),
                        onPressed: (){
                          logout_twitter();
                        },
                      )
                    ]
                )
                    :OutlineButton(
                  child: Text("Login using Twitter",style: TextStyle(fontFamily: 'Roboto',fontSize: 12,fontStyle: FontStyle.italic)),
                  onPressed: (){
                    login_twitter();
                  },
                )



              ]
            )
        )
    );
  }


  login_facebook() async{
    try {
      final result = await facebookLogin.logIn(['email']);

      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          final token = result.accessToken.token;
          final graphResponse = await http.get(
              'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${token}');
          final profile = JSON.jsonDecode(graphResponse.body);
          print(profile);
          setState(() {
            userProfile = profile;
            isFacebookLoggedIn = true;
          });
          break;

        case FacebookLoginStatus.cancelledByUser:
          setState(() => isFacebookLoggedIn = false);
          break;
        case FacebookLoginStatus.error:
          setState(() => isFacebookLoggedIn = false);
          break;
      }
    }
    catch(err){
      print("Exception : ${err}");
    }
  }

   logout_facebook() {
     facebookLogin.logOut();
     setState(() {
       isFacebookLoggedIn = false;
     });
  }

  login_google() async{
    try{
      await _googleSignIn.signIn();
      setState(() {
        isGoogleLoggedIn=true;
      });
    }
    catch(err){
      print("Exception : ${err}");
    }
  }

   logout_google() {
    _googleSignIn.signOut();
    setState(() {
      isGoogleLoggedIn=false;
    });
  }

   login_twitter() async {
     try {

       var twitterLogin = new TwitterLogin(
         consumerKey: '9nr9tgJX6uUG6Gh9lih7VDwUy',
         consumerSecret: 'HITPf4qrjBBU0qExFpqlm34Urm1Y131YbH625DAX3AQytlRpOb',
       );
       final TwitterLoginResult result = await twitterLogin.authorize();
       FirebaseUser fbuser;
       switch (result.status) {
         case TwitterLoginStatus.loggedIn:
           var session = result.session;
           fbuser = (await _auth.signInWithCustomToken(token: session.token).then((response){
              if(response!=null){
                _user=fbuser;
                setState(() => isTwitterLoggedIn = true);
              }
            return _user;
           }));
           break;
         case TwitterLoginStatus.cancelledByUser:
           setState(() => isTwitterLoggedIn = false);
           break;
         case TwitterLoginStatus.error:
           setState(() => isTwitterLoggedIn = false);
           break;
       }

     }
     catch(err){
       print("Exception: ${err}");
     }
   }

   logout_twitter() {
     setState(() {
       isTwitterLoggedIn=false;
     });

   }
}
