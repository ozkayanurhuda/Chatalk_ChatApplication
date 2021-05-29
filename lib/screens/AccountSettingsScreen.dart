import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:chatalk_chat_application/components/LogoutButton.dart';
import 'package:chatalk_chat_application/components/UpdateButton.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:chatalk_chat_application/widgets/ProgressWidget.dart';
import 'package:chatalk_chat_application/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart' as storageRef;
import 'package:chatalk_chat_application/constants.dart';
// import 'package:path/path.dart' as Path;


class PreSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: white,
          icon:Icon(Icons.arrow_back_ios_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
        iconTheme: IconThemeData(
          color:white,
        ),
        backgroundColor: primaryColor,
        title: Text("Settings",
        style:titleTextStyle),
        centerTitle: true,
      ),
      body: SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  State createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  //text editing cont for features
  TextEditingController nickNametextEditingController;
  TextEditingController aboutMetextEditingController;

  SharedPreferences preferences;
  String id = "";
  String nickname = "";
  String aboutMe = "";
  String photoUrl = "";
  File imageFileAvatar;
  bool isLoading = false;
  final FocusNode nicknameFocusNode = FocusNode();
  final FocusNode aboutMeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    //kullanıcı bilgilerini okuma
    readDataFromLocal();
  }

  void readDataFromLocal() async {

    //we received data from the local and we stored it in the id,nick vs
    preferences = await SharedPreferences.getInstance();
    id= preferences.getString("id");
    nickname= preferences.getString("nickname");
    aboutMe= preferences.getString("aboutMe");
    photoUrl= preferences.getString("photoUrl");

    nickNametextEditingController=TextEditingController(text: nickname);
    aboutMetextEditingController=TextEditingController(text: aboutMe);

    //see the infos - force refresh input
    setState(() {
    });
  }
///------------------------Pick Image From The Gallery--------------------------
  Future getImage() async {

    // var newImageFile = await ImagePicker().getImage(source: ImageSource.gallery) as File;
    //File newImageFile = await ImagePicker.pickImage(source:ImageSource.gallery);
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);

    File newImageFile = File(pickedFile.path);
    if(newImageFile != null) {
      setState(() {
        imageFileAvatar=newImageFile;
        isLoading=true;
      });
    }
    uploadImageToFirestoreAndStorage();
  }
///------------------------------UPLOAD IMAGE********---------------------------
  Future uploadImageToFirestoreAndStorage() async
  {
    String mFileName=id;

    storageRef.Reference storageReference =FirebaseStorage.instance.ref().child(mFileName);

    storageRef.UploadTask storageUploadTask=storageReference.putFile(imageFileAvatar);

    storageRef.TaskSnapshot storageTaskSnapshot = await storageUploadTask.whenComplete(() {});

    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    photoUrl=downloadUrl;

    //update pp
    FirebaseFirestore.instance.collection("users").doc(id).update({
      "photoUrl": photoUrl,
      "aboutMe": aboutMe,
      "nickname" : nickname,
    }).then((data) async {
      await preferences.setString("photoUrl", photoUrl);

      setState(() {
        isLoading=false;
        // photoUrl=downloadUrl;
      });
      Fluttertoast.showToast(msg: "Updated Successfully.");
    });
  }
  ///----------------------------updateData (update) for button-----------------
 void updateData()  {

    nicknameFocusNode.unfocus();
    aboutMeFocusNode.unfocus();

    setState(() {
      isLoading=false;
    });

    //update all data
    FirebaseFirestore.instance.collection("users").doc(id).update({
      "photoUrl":photoUrl,
      "aboutMe":aboutMe,
      "nickname":nickname,
    }).then((data) async {
      await preferences.setString("photoUrl", photoUrl);
      await preferences.setString("aboutMe", aboutMe);
      await preferences.setString("nickname", nickname);

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Updated Successfully.");
    });
  }
///--------------------------------PROFILE IMAGE AVATAR-------------------------
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              //profile image avatar
              Container(
                child: Center(
                  child: Stack(
                    //changing profile picture
                    children: [
                      (imageFileAvatar==null)
                          ? (photoUrl != "")
                          ? Material(
                        ///display already existing-old image file
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                            width: 200.0,
                            height: 200.0,
                            padding: EdgeInsets.all(20.0),
                          ),
                          imageUrl: photoUrl,
                          width: 200.0,
                          height: 200.0,
                          fit:BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(125.0)),
                        clipBehavior: Clip.hardEdge,
                      )
                      //no pp
                          : Icon(Icons.account_circle, size:90.0, color: greyColor,)
                      //pick new pp
                          : Material(
                        ///yeni foto seç display the updated image here
                        child: Image.file(
                          imageFileAvatar,
                          width: 200.0,
                          height: 200.0,
                          fit:BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(125.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      IconButton(
                        icon:Icon(
                          Icons.camera_alt,
                          size:100.0,
                          color:white.withOpacity(0.3),
                        ),
                        //tıklandığında yeni foto seç
                        onPressed: getImage,
                        padding: EdgeInsets.all(0.0),
                        splashColor: Colors.transparent,
                        highlightColor: greyColor,
                        iconSize: 200.0,
                      ),
                    ],
                  ),
                ),
                width: double.infinity,
                margin:EdgeInsets.all(20.0),
              ),
///-------------------------------INPUT FIELDS----------------------------------
              //Input Fields
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: isLoading ? circularProgress(): Container(),
                  ),
//------------------------------------Username----------------------------------
                  Container(
                    child: Text(
                      "Name",
                      style: accountSettingTextStyle,
                    ),
                    margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 30.0),
                  ),
                  //input dec
                  Container(
                    child: Theme(
                      data:Theme.of(context).copyWith(primaryColor: primaryColor),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "e.g Nurhüda Özkaya",
                          // contentPadding: EdgeInsets.symmetric(horizontal: 2.0,vertical: 2.0),
                          hintStyle: TextStyle(
                            color: greyColor,
                          ),
                        ),
                        //change the nickname
                        controller: nickNametextEditingController,
                        onChanged: (value){
                          nickname=value;
                        },
                        focusNode: nicknameFocusNode,
                      ),
                    ),
                    margin:EdgeInsets.symmetric(vertical:5.0,horizontal: 30.0),
                  ),
                  SizedBox(height: 20.0,),
//----------------------------------AboutMe-------------------------------------
                  Container(
                    child: Text(
                      "Status",
                      style: accountSettingTextStyle,
                    ),
                    margin: EdgeInsets.symmetric(vertical: 5.0,horizontal: 30.0),
                  ),
                  //input dec
                  Container(
                    child: Theme(
                      data:Theme.of(context).copyWith(primaryColor: primaryColor),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Status",
                          // contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(
                            color: greyColor,
                          ),
                        ),
                        //change the about me
                        controller: aboutMetextEditingController,
                        onChanged: (value){
                          aboutMe=value;
                        },
                        focusNode: aboutMeFocusNode,
                      ),
                    ),
                    margin:EdgeInsets.symmetric(vertical:5.0,horizontal: 30.0),
                  ),
                ],
              ),
//-----------------------Button to Update & Logout------------------------------
            UpdateButton(onPressed: updateData),
            LogoutButton(onPressed: logoutUser),
            ],
          ),
          // padding:EdgeInsets.only(left: 15.0,right: 15.0),
        ),
      ],
    );
  }
//----------------------------SIGNOUT-------------------------------------------
  final GoogleSignIn googleSignIn= GoogleSignIn();

  Future<Null> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    this.setState(() {
      isLoading=false;
    });

    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MyApp()),
            (Route<dynamic> route) => false);
  }
}