import 'dart:async';
import 'dart:io';
import 'package:chatalk_chat_application/models/user.dart';
import 'package:chatalk_chat_application/screens/AccountSettingsScreen.dart';
import 'package:chatalk_chat_application/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatalk_chat_application/screens/ChatScreen.dart';
import 'package:chatalk_chat_application/constants.dart';

class HomeScreen extends StatefulWidget {

  final String currentUserId ;
  HomeScreen({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => HomeScreenState(currentUserId:currentUserId);
}

class HomeScreenState extends State<HomeScreen> {

  TextEditingController searchTextEditingController = TextEditingController();
  Future <QuerySnapshot> futureSearchResults;

  final String currentUserId;
  HomeScreenState({Key key, @required this.currentUserId});

///------------------------------APPBAR----------------------------------
  homeScreenHeader() {
    return AppBar(
      automaticallyImplyLeading: false, //remove back button
      //send the user to account settings page
      actions: [
        IconButton(
          icon:Icon(Icons.settings_rounded, size: 30.0,color:white),
          onPressed:() {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PreSettings()));
          },
        ),
      ],
      backgroundColor: primaryColor,
      title: Container(
        margin: new EdgeInsets.symmetric(vertical: 3.0,horizontal: 3.0),
        child: TextFormField(
          style: TextStyle(fontSize: 18.0, color: white),
          controller: searchTextEditingController,
          decoration: InputDecoration(
            hintText: "Search...",
            hintStyle: TextStyle(color: white),
            // enabledBorder: UnderlineInputBorder(
            //   borderSide: BorderSide(color: Colors.grey),
            // ),
            // focusedBorder: UnderlineInputBorder(
            //   borderSide: BorderSide(color: Colors.white),
            // ),
            filled: true,
            //for person pin in pre
            prefixIcon: Icon(Icons.search_rounded,
              color: white,
              size: 32.0,),
            //for close the searched word
            suffixIcon: IconButton(
              icon: Icon(Icons.clear_rounded,
              color: white),
              onPressed: emptyTextFormField,
          ),
        ),
          //search for username
          onFieldSubmitted: controlSearching,
      ) ,
      ),
    );
  }
///-----------------------------search for username -----------------------------
  controlSearching(String userName) {
    Future<QuerySnapshot> allFoundUsers= FirebaseFirestore.instance.collection("users")
        .where("nickname", isGreaterThanOrEqualTo: userName).get();
    //assign it to future search results
    setState(() {
      futureSearchResults=allFoundUsers;
    });
  }
  //clear text search field
  emptyTextFormField() {
    searchTextEditingController.clear();
  }

///------------------------------------BODY--------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeScreenHeader(),
      //find searched person
      body:futureSearchResults==null ? displayNoSearchResultScreen() : displayUserFoundScreen(),
    );
  }
//-------------------------------Aranan kullanıcı bulunduysa--------------------
  displayUserFoundScreen() {
    return FutureBuilder(
      future: futureSearchResults,
      builder: (context, dataSnapshot) {
        if(!dataSnapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchUserResult= [];

        dataSnapshot.data.docs.forEach((document) {
         UserInformations eachUser=UserInformations.fromDocument(document);
         UserResult userResult=UserResult(eachUser);

          if(currentUserId!=document["id"]) {
            searchUserResult.add(userResult);
          }
        });
        return ListView(children:searchUserResult);
      }
    );
  }

//------------------------Aranan kullanıcı bulunmadıysa-------------------------
  displayNoSearchResultScreen() {
    // final Orientation orientation= MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Icon(Icons.group_rounded, color:primaryColor, size:200.0),
            Text(
              "Search Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryColor, fontSize: 50.0, fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//---------------------------result of searched ---------------------------
class UserResult extends StatelessWidget {

  final UserInformations eachUser;
  UserResult(this.eachUser);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:EdgeInsets.all(4.0),
      child: Container(
        color:white,
        child:Column(
          children: [
            //kişiye dokununca chat sayfasına gonder
            GestureDetector(
              onTap:() => sendUserToChatPage(context),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:greyColor,
                  backgroundImage: CachedNetworkImageProvider(eachUser.photoUrl),
                ),
                title: Text(
                  eachUser.nickname,
                  style: TextStyle(
                    color: black,fontSize: 16.0,fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "Joined" + DateFormat("dd MMMM, yyyy - hh:mm:aa")
                      .format(DateTime.fromMicrosecondsSinceEpoch(
                      int.parse(eachUser.createdAt))),
                  style: TextStyle(
                    color:greyColor,
                    fontSize: 14.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
//------------------click the page then nav user to chat sc----------------
  sendUserToChatPage(BuildContext context) {

    Navigator.push(context, MaterialPageRoute(
        builder: (context)=> Chat(

          receiverId: eachUser.id,
          receiverAvatar: eachUser.photoUrl,
          receiverName: eachUser.nickname,

        )));
  }
}