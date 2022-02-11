import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String postId;
  final String username;
  final String uid;
  final datePublished;
  final String postUrl;
  final String profImage;
  final likes;

  const Post({
    required this.uid,
    required this.description,
    required this.datePublished,
    required this.username,
    required this.postId,
    required this.postUrl,
    required this.profImage,
    required this.likes,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'description': description,
    'postId': postId,
    'datePublished': datePublished,
    'uid': uid,
    'postUrl': postUrl,
    'profImage': profImage,
    'likes' : likes,
  };

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
      uid: snapshot['uid'],
      username: snapshot['username'],
      likes: snapshot['likes'],
      postId: snapshot['postId'],
      datePublished: snapshot['datePublished'],
      description: snapshot['description'],
      postUrl: snapshot['postUrl'],
      profImage: snapshot['profImage'],
    );
  }
}
