import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Artis_Tree/models/Rev.dart';
import 'package:Artis_Tree/models/post.dart';
import 'package:Artis_Tree/pages/progress.dart';
import 'package:uuid/uuid.dart';
import './home.dart';

class PostScreen extends StatefulWidget {
  final String postId;

  PostScreen({this.postId});

  @override
  PostScreen1 createState() => PostScreen1();
}

class PostScreen1 extends State<PostScreen> {
  List<String> f = [];
  Fid fid;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: postsRef
            .document(currentUser.sellerId)
            .collection('userPosts')
            .document(widget.postId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          Post post = Post.fromDocument(snapshot.data);
          return Scaffold(
            backgroundColor: Colors.pink[100],
            appBar: AppBar(
              centerTitle: true,
              title: Text(post.item),
            ),
            body: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Container(
                  child: post,
                ),
                Divider()
              ],
            ),
          );
        },
      ),
    );
  }
}
