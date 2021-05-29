import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatalk_chat_application/screens/HomeScreen.dart';
import 'package:chatalk_chat_application/widgets/ProgressWidget.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class LoginScreen extends StatefulWidget {

  LoginScreen({Key key}) : super (key:key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {

  final GoogleSignIn googleSignIn=GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences preferences;

  bool isLoggedIn = false;
  bool isLoading= false;
  User currentUser;

//--------------------------------isSignedIn------------------------------------
  @override
  void initState() {
    super.initState();
    isSignedIn();
  }

  void isSignedIn() async {
    this.setState(() {
      isLoggedIn=true;
    });

    preferences=await SharedPreferences.getInstance();
    isLoggedIn=await googleSignIn.isSignedIn();
    if(isLoggedIn) {
      Navigator.push(context, MaterialPageRoute(
          builder:(context)=> HomeScreen(
              currentUserId:preferences.getString("id"))));
    }
    //circular move false
    this.setState(() {
      isLoading=false;
    });
  }
//-------------------------------------BODY DESIGN----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.red[300],Colors.indigo[400]],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'logo',
                    child: Container(
                      height: 200.0,
                      child: Image.asset(
                        'images/prim.png',
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Chatalk',
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                      fontSize: 40.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
                isRepeatingAnimation: true,
              ),
              SizedBox(
                height: 30.0,
              ),
              GestureDetector(
                onTap:controlSignIn,
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 250.0,
                        height: 60.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          image: DecorationImage(
                            image:
                                AssetImage("images/google_signin_button.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(1.0),
                child: isLoading ? circularProgress() : Container(),
              )
            ],
          )),
    );
  }
  //--------------------------GOOGLE SIGN IN FIREBASE---------------------------
  ///display the circular progress
  ///for google signin firebase auth
  Future<Null> controlSignIn() async {
    preferences= await SharedPreferences.getInstance();

    this.setState(() {
      isLoading=true;
    });

    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuthentication = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuthentication.idToken,
      accessToken: googleAuthentication.accessToken,
    );
    User firebaseUser= (await FirebaseAuth.instance.signInWithCredential(credential)).user;

    ///signin success
    if(firebaseUser!= null) {
      ///check if already Sign up
      ///changed like this
      final QuerySnapshot resultQuery = await FirebaseFirestore.instance
          .collection("users").where("id", isEqualTo:firebaseUser.uid).get();
      final List<DocumentSnapshot> documentSnapshots = resultQuery.docs;

      ///if no docs
      ///save data to firestore - if new user
      if(documentSnapshots.length==0) {
        FirebaseFirestore.instance.collection("users").doc(firebaseUser.uid).set({
          "nickname": firebaseUser.displayName,
          "photoUrl": firebaseUser.photoURL,
          "id": firebaseUser.uid,
          "aboutMe":"I am using Chatalk Chat App!",
          "createdAt":DateTime.now().millisecondsSinceEpoch.toString(),
          "chattingTime":null,
        });

        ///Write data to local
        currentUser = firebaseUser;
        await preferences.setString("id",currentUser.uid);
        await preferences.setString("nickname",currentUser.displayName);
        await preferences.setString("photoUrl",currentUser.photoURL);

      } else {
        ///if not new user, write it instead old infos
        ///make changes
        ///write data to local
        currentUser = firebaseUser;
        await preferences.setString("id",documentSnapshots[0]["id"]);
        await preferences.setString("nickname",documentSnapshots[0]["nickname"]);
        await preferences.setString("photoUrl",documentSnapshots[0]["photoUrl"]);
        await preferences.setString("aboutMe",documentSnapshots[0]["aboutMe"]);
      }

      ///sign in succesfully
      Fluttertoast.showToast( msg: 'Congratulations, Sign in Successful.');
      this.setState(() {
        isLoading=false;
      });

      ///navigate to home screen
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: firebaseUser.uid )));

      ///sign in not successfully
    } else {
      Fluttertoast.showToast( msg: 'Try Again, Sign in Failed.');
      this.setState(() {
        isLoading=false;
      });
    }
  }
}
