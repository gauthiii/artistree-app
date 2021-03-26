import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Img extends StatefulWidget {
  final String url;

  Img({this.url});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Img> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CachedNetworkImage(
        fit: BoxFit.fill,
        imageUrl: widget.url,
        placeholder: (context, url) => Padding(
          child: CircularProgressIndicator(),
          padding: EdgeInsets.all(4),
        ),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }
}
