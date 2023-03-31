import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String postId;
  String userId;
  String title;
  String text;
  String imageUrl;
  Timestamp timestamp;

  Post({
    required this.postId,
    required this.userId,
    required this.title,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
  });
}