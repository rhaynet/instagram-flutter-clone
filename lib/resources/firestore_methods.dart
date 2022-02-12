import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/models/posts.dart';
import 'package:instagram_clone/resources/storage_method.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //upload posts
  Future<String> uploadPost(
      String description,
      Uint8List file,
      String uid,
      String username,
      String profImage,
      ) async {
    String res = 'some error occurred';
    try {
      String photoUrl = await StorageMethod().uploadImageToStorage(
          'posts', file, true);

      String postId = const Uuid().v1();
      Post post = Post(
        uid: uid,
        description: description,
        datePublished: DateTime.now(),
        username: username,
        postId: postId,
        postUrl: photoUrl,
        profImage: profImage,
        likes: [],
        );

      await _firestore.collection('posts').doc(postId).set(post.toJson());
      res = 'success';
    } catch (err){
      res = err.toString();
    }
    return res;
  }


  Future<void> likePost(String postId, String uid, List likes)async{
    try{
      if(likes.contains(uid)){
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      }else{
        _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([uid]),
        });
      }
    }catch(e){
      print(e.toString());
    }
  }

  Future<void> postComment(String postId, String text, String uid,String name, String profilePic)async{
    try{
      String commentId = const Uuid().v1();
      if(text.isNotEmpty){
        await _firestore.collection('posts').doc(postId).collection('comments').doc(commentId).set({
          'profilePic': profilePic,
          'name' : name,
          'uid' : uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
      }else{
        print('Text is empty');
      }
    }catch(err){
      print(err.toString());
    }
  }


  //deleting posts
  Future<void> deletePost(String postId) async{
    try{
      _firestore.collection('posts').doc(postId).delete();
    }catch(e){
      print(e.toString());
    }
  }

  Future<void> followUser(
      String uid,
      String followId
      ) async {
    try {
      DocumentSnapshot snap = await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if(following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }

    } catch(e) {
      print(e.toString());
    }
  }

  Future<void> signOut() async{
    await _auth.signOut();
  }
}

