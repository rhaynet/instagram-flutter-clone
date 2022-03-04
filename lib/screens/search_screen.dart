import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Search for a user...',
          ),
          onFieldSubmitted: (String _) {
            setState(() {
              isShowUsers = true;
            });
            print(_);
          },
        ),
      ),
      body: isShowUsers
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where('username',
                      isGreaterThanOrEqualTo: searchController.text,)
                  .get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(uid: snapshot.data!.docs[index]['uid']),
                    ),
                  );
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      snapshot.data!.docs[index]['photoUrl'],
                    ),
                    radius: 16,
                  ),
                  title: Text(snapshot.data!.docs[index]['username']),
                ),
              );
            },
          );
        },
            )
          : FutureBuilder(
              future: FirebaseFirestore.instance.collection('posts').orderBy('datePublished').get(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return StaggeredGridView.countBuilder(
                  crossAxisCount: 3,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                        snapshot.data!.docs[index].data()['postUrl'], fit: BoxFit.cover,);
                  },
                  staggeredTileBuilder: (index) => StaggeredTile.count(
                    (index % 7 == 0) ? 2 : 1,
                    (index % 7 == 0) ? 2 : 1,
                  ),
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                );
              },
            ),
    );
  }
}
