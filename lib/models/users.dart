import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String bio;
  final String username;
  final String photoUrl;
  final String uid;
  final List followers;
  final List following;

  const User({
    required this.uid,
    required this.email,
    required this.bio,
    required this.username,
    required this.photoUrl,
    required this.followers,
    required this.following,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'photoUrl': photoUrl,
        'bio': bio,
        'uid': uid,
        'followers': followers,
        'following': following,
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      uid: snapshot['uid'],
      email: snapshot['email'],
      bio: snapshot['bio'],
      username: snapshot['username'],
      photoUrl: snapshot['photoUrl'],
      followers: snapshot['followers'],
      following: snapshot['following'],
    );
  }
}
