import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/users.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/comment_card.dart';
import 'package:provider/provider.dart';

class CommentScreen extends StatefulWidget {
  const CommentScreen({Key? key, required this.snap}) : super(key: key);

  final snap;

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentEditingController =
      TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _commentEditingController.dispose();
  }

  void postComment(String uid, String name, String profilePic) async {
    try {
      String res = await FirestoreMethods().postComment(
        widget.snap,
        _commentEditingController.text,
        uid,
        name,
        profilePic,
      );

      if (res != 'success') {
        showSnackBar(context, res);
      }
      setState(() {
        _commentEditingController.text = "";
      });
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('Comments'),
        centerTitle: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.snap)
            .collection('comments')
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) => CommentCard(
              snap: snapshot.data!.docs[index].data(),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user.photoUrl),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: TextField(
                    controller: _commentEditingController,
                    decoration: InputDecoration(
                      hintText: 'Comment as ${user.username}',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => postComment(
                  user.uid,
                  user.username,
                  user.photoUrl,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: const Text(
                    'Post',
                    style: TextStyle(
                      color: blueColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
