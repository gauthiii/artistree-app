import 'package:flutter/material.dart';
import 'package:Artis_Tree/models/post.dart';
import 'package:Artis_Tree/models/tile_builder.dart';
import 'package:Artis_Tree/pages/post_screen.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostScreen(
                postId: post.postId,
              ),
            ),
          );
        },
        child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0)),
            color: Colors.pink[100],
            elevation: 5.0,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(50.0)),
              child: cachedNetworkImage(post.mediaUrl),
            )));
  }
}
