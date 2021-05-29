import 'dart:async';
import 'dart:io';
import 'package:chatalk_chat_application/components/EmojiTextButton.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as storageRef;
import 'package:chatalk_chat_application/widgets/FullImageWidget.dart';
import 'package:chatalk_chat_application/widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

///------------------------------Receiver Infos---------------------------------
class Chat extends StatelessWidget {
  final String receiverId;
  final String receiverAvatar;
  final String receiverName;

  Chat({
    Key key,
    @required this.receiverId,
    @required this.receiverAvatar,
    @required this.receiverName,
  });

  ///---------------------------------AppBar--------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:Icon(Icons.arrow_back_ios_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor:primaryColor,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: black,
              backgroundImage: CachedNetworkImageProvider(receiverAvatar),
            ),
          ),
        ],
        iconTheme: IconThemeData(color: white),
        title: Text(
          receiverName,
          style: TextStyle(color: white, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: ChatScreen(receiverId: receiverId, receiverAvatar: receiverAvatar),
    );
  }
}

///-------------------------------------BODY------------------------------------
class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverAvatar;

  ChatScreen({
    Key key,
    @required this.receiverId,
    @required this.receiverAvatar,
  }) : super(key: key);

  @override
  State createState() =>
      ChatScreenState(receiverId: receiverId, receiverAvatar: receiverAvatar);
}

class ChatScreenState extends State<ChatScreen> {
  final String receiverId;
  final String receiverAvatar;

  ChatScreenState({
    Key key,
    @required this.receiverId,
    @required this.receiverAvatar,
  });

  List<QueryDocumentSnapshot> listMessage= new List.from([]);

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  bool isDisplaySticker;
  bool isLoading;

  File imageFile;
  String imageUrl;

  String chatId;
  SharedPreferences preferences;
  String id;
  // var listMessage;
//---------------------------------3---------------------------
  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);

    //when u click then it will open
    isDisplaySticker = false;
    isLoading = false;
    //imageUrl = '';

    chatId = "";
    //read local storage
    readLocal();
  }

//---------------------------------12--------------------------
// read local from storage
  readLocal() async {
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id") ?? "";

    if (id.hashCode <= receiverId.hashCode) {
      chatId = '$id-$receiverId';
    } else {
      chatId = '$receiverId-$id';
    }

    FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .update({'chattingWith': receiverId});

    setState(() {});
  }

//---------------------------4-----------------------
  //başka yere tıklandığında sticker sekmesini kapat
  onFocusChange() {
    if (focusNode.hasFocus) {
      //hide stickers whenever keypad appears
      setState(() {
        isDisplaySticker = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              //create List of Messages
              createListMessages(),

              //Show Stickers
              //tıklanınca aç otherwise boş cont
              (isDisplaySticker ? createStickers() : Container()),

              //Input Controllers
              createInput(),
            ],
          ),
          createLoading(),
        ],
      ),
      onWillPop: onBackPress,
    );
  }

//------------------------8yüklenirken------------------------------------
  createLoading() {
    return Positioned(
      child: isLoading ? circularProgress() : Container(),
    );
  }

//------------------------------7geri tuşuna basıldığında-----------------------
  //sticker açıksa onu kapat değilse geri git
  Future<bool> onBackPress() {
    if (isDisplaySticker) {
      setState(() {
        isDisplaySticker = false;
      });
    } else {
      //geri git
      Navigator.pop(context);
    }
    return Future.value(false);
  }

//----------------------------5CREATE STICKERS--------------------------
  Widget createStickers() {
    return Container(
      child: Column(
        children: <Widget>[
          ///-------------------------ROWS FOR STICKERS
          Expanded(
            child: Row(
              children: <Widget>[
                EmojiTextButton(
                  onPressed: () => onSendMessage("mimi1", 2),
                  stickerImage: "images/mimi1.gif",
                ),
                EmojiTextButton(
                  onPressed: () => onSendMessage("mimi2", 2),
                  stickerImage: "images/mimi2.gif",
                ),
                EmojiTextButton(
                  onPressed: () => onSendMessage("mimi3", 2),
                  stickerImage: "images/mimi3.gif",
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                EmojiTextButton(
                  onPressed: () => onSendMessage("mimi4", 2),
                  stickerImage: "images/mimi4.gif",
                ),
                EmojiTextButton(
                  onPressed: () => onSendMessage("mimi5", 2),
                  stickerImage: "images/mimi5.gif",
                ),
                EmojiTextButton(
                  onPressed: () => onSendMessage("mimi6", 2),
                  stickerImage: "images/mimi6.gif",
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                EmojiTextButton(
                  onPressed: () => onSendMessage("mimi7", 2),
                  stickerImage: "images/mimi7.gif",
                ),
                EmojiTextButton(
                  onPressed: () => onSendMessage("mimi8", 2),
                  stickerImage: "images/mimi8.gif",
                ),
                EmojiTextButton(
                  onPressed: () => onSendMessage("mimi9", 2),
                  stickerImage: "images/mimi9.gif",
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: greyColor, width: 0.5)),
          color: white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

//--------------6Bir stickera bastığında sticker penceresinin kapat vice versa-------------------
  void getSticker() {
    focusNode.unfocus();
    setState(() {
      isDisplaySticker = !isDisplaySticker;
    });
  }

//---------------------------2CREATE LIST MESSAGES------------------------------
  Widget createListMessages() {
    return Flexible(
      //if there is no chat
      child: chatId == ""
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ) //if there is chat
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("messages")
                  .doc(chatId)
                  .collection(chatId)
                  .orderBy("timestamp", descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                //if no data for this person
                {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  );
                } else
                //if hasData save data one by one to our list
                {
                  listMessage = snapshot.data.docs;
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        createItem(index, snapshot.data.docs[index]),
                    itemCount: snapshot.data.docs.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }

//----------------------------------14-----------------------------------
  bool isLastMsgLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]["idFrom"] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMsgRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]["idFrom"] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

//-----------------------------------------13----------------------------------
  Widget createItem(int index, DocumentSnapshot document) {
//----------------------My messages - Right Side--------------------------------
    //we store content, idFrom, idTo, timestamp, type
    if (document["idFrom"] == id) {
      return Row(
        children: <Widget>[
//------------------------------Text Msg----------------------------------------
          document["type"] == 0
              ? Container(
                  child: Text(
                    document["content"],
                    style: TextStyle(
                        color: white, fontWeight: FontWeight.w500),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  width: 180.0,
                  decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30.0),
                          topLeft: Radius.circular(30.0),
                          bottomRight: Radius.circular(30.0))),
                  margin: EdgeInsets.only(bottom: 10.0, right: 10.0),
                )
//-----------------------------Image Msg----------------------------------------
              : document["type"] == 1
                  ? Container(
                      child: TextButton(
                        child: Material(
                          child: CachedNetworkImage(
                            ///it will display the placeholder until url
                            ///retrieved successfully from the database
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    primaryColor),
                              ),
                              width: 200.0,
                              height: 200.0,
                              padding: EdgeInsets.all(70.0),
                              decoration: BoxDecoration(
                                color: greyColor,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(30.0),
                                    topLeft: Radius.circular(30.0),
                                    bottomRight: Radius.circular(30.0)),
                              ),
                            ),

                            ///images not retrieved successfully or if there is any error occured
                            errorWidget: (context, url, error) => Material(
                              child: Image.asset(
                                "images/img_not_available.jpeg",
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              clipBehavior: Clip.hardEdge,
                            ),

                            ///if image is correct, display the image
                            imageUrl: document["content"],
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30.0),
                              topLeft: Radius.circular(30.0),
                              bottomRight: Radius.circular(30.0)),
                          clipBehavior: Clip.hardEdge,
                        ),

                        ///onPressed go to full screen size image
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FullPhoto(url: document.data()["content"])));
                        },
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMsgRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    )
//--------------------Sticker .gif Msg(otherwise)-------------------------------
                  : Container(
                      child: Image.asset(
                        "images/${document.data()['content']}.gif",
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                      margin: EdgeInsets.only(
                          bottom: 10.0,
                          right: 10.0),
                    ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    }
//-----------------------Receiver Messages - Left Side--------------------------
    else {
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMsgLeft(index)
                    ? Material(
//-----------------display receiver profile image-------------------------------
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                            width: 35.0,
                            height: 35.0,
                            padding: EdgeInsets.all(10.0),
                          ),
                          imageUrl: receiverAvatar,
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(
                        width: 35.0,
                      ),
//----------------------------displayMessages-----------------------------------
                ///Text Msg
                document["type"] == 0
                    ? Container(
                        child: Text(
                          document["content"],
                          style: TextStyle(
                              color:black, fontWeight: FontWeight.w500),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 170.0,
                        decoration: BoxDecoration(
                            color: kellyGreen,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30.0),
                              topRight: Radius.circular(30.0),
                              bottomRight: Radius.circular(30.0),
                            ),),
                        margin: EdgeInsets.only(left: 10.0),
                      )

                    ///Image Msg
                    : document["type"] == 1
                        ? Container(
                            child: TextButton(
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          primaryColor),
                                    ),
                                    width: 200.0,
                                    height: 200.0,
                                    padding: EdgeInsets.all(70.0),
                                    decoration: BoxDecoration(
                                      color: greyColor,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(30.0),
                                        topRight: Radius.circular(30.0),
                                        bottomRight: Radius.circular(30.0),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    child: Image.asset(
                                      "images/img_not_available.jpeg",
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius:
                                    BorderRadius.only(
                                      bottomLeft: Radius.circular(30.0),
                                      topRight: Radius.circular(30.0),
                                      bottomRight: Radius.circular(30.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl: document.data()["content"],
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FullPhoto(
                                            url: document.data()["content"])));
                              },
                            ),
                            margin: EdgeInsets.only(left: 10.0),
                          )

                        ///Sticker .gif Msg
                        : Container(
                            child: Image.asset(
                              "images/${document['content']}.gif",
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(
                                bottom: 10.0,
                                right: 10.0),
                          ),
              ],
            ),

            ///Msg time
            ///son mesajsa süreyi göster altta
            isLastMsgLeft(index)
                ? Container(
                    child: Text(
                      DateFormat("dd MMMM, yyyy - hh:mm:aa").format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document["timestamp"]))),
                      style: TextStyle(
                          color: greyColor,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 10.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

//----------------------------1CREATE INPUT------------------------
  Widget createInput() {
    return Container(
      child: Row(
        children: <Widget>[
//--------------------------PICK IMAGE ---------------------------------
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                color: primaryColor,
                onPressed: getImage,
              ),
            ),
            color: white,
          ),

//------------------------EMOJI ICON BUTTON---------------------------
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.face),
                color: primaryColor,
                onPressed: getSticker,
              ),
            ),
            color: white,
          ),

//---------------------------TEXT FIELD-------------------------
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(
                  color: black,
                  fontSize: 16.0,
                ),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: "Type a message...",
                  hintStyle: TextStyle(color: greyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

//----------------------------SEND ICON------------------------------
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.send),
                color: primaryColor,
                onPressed: () => onSendMessage(textEditingController.text, 0),
              ),
            ),
            color: white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: primaryColor,
            width: 0.5,
          ),
        ),
        color: white,
      ),
    );
  }

//---------------------------------11-------------------------------
//****************************1 for image,2 for sticker, 0 for text ******************
  void onSendMessage(String contentMsg, int type) {
    //type=0 its text msg
    //type=1 its imageFile
    //type=2 its sticker-emoji-gifs

    if (contentMsg.trim() != '') {
      //mesaj gönderdiğinde texteditingCont temizle
      textEditingController.clear();

      var docRef = FirebaseFirestore.instance
          .collection("messages")
          .doc(chatId)
          .collection(chatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          docRef,
          {
            "idFrom": id,
            "idTo": receiverId,
            "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
            "content": contentMsg,
            "type": type,
          },
        );
      });
      //Animates the position from its current value to the given value.
      listScrollController.animateTo(0.0,
          duration: Duration(microseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(
          msg: "Empty Message. Can not be send.",
          backgroundColor: black,
          textColor: Colors.red);
    }
  }

//----------------------------9GET IMAGE--------------------------
  ImagePicker imagePicker = ImagePicker();
  Future getImage() async {
    final pickedFile = await imagePicker.getImage(source: ImageSource.gallery);

    File file = File(pickedFile.path);

    //this was also error :)
    setState(() {
      imageFile = file;
      isLoading = true;
    });

    uploadImageFile(imageFile);
  }

//-------------------------10UPLOAD IMAGE------------------------------
  Future uploadImageFile(File imageFileNew) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    storageRef.Reference storageReference =
        FirebaseStorage.instance.ref().child(fileName);

    storageRef.UploadTask storageUploadTask =
         storageReference.putFile(imageFileNew);

    storageRef.TaskSnapshot storageTaskSnapshot =
        await storageUploadTask.whenComplete(()
        {

        });

    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    imageUrl = downloadUrl;

    setState(() {
      isLoading = false;
      onSendMessage(imageUrl, 1);
    });
  }
}
