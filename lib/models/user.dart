import 'package:cloud_firestore/cloud_firestore.dart';

class UserInformations {
  final String id;
  final String nickname;
  final String photoUrl;
  final String createdAt;

  UserInformations({
    this.id,
    this.nickname,
    this.photoUrl,
    this.createdAt,
  });

  factory UserInformations.fromDocument(DocumentSnapshot doc) {
    return UserInformations(
      //documentID
      id: doc.id,
      photoUrl: doc.data()['photoUrl'],
      nickname: doc['nickname'],
      createdAt: doc['createdAt'],
    );
  }
}