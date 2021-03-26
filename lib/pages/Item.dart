import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:Artis_Tree/models/Rev.dart';
import 'package:Artis_Tree/models/post.dart';
import 'package:Artis_Tree/pages/img.dart';
import 'package:Artis_Tree/pages/progress.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import './home.dart';
import 'place_order.dart';

class PostScreenX extends StatefulWidget {
  final String postId;

  PostScreenX({this.postId});

  @override
  PostScreen1 createState() => PostScreen1();
}

class PostScreen1 extends State<PostScreenX> {
  List<String> f = [];
  int t = 1;
  Fid fid;
  Post post;
  @override
  void initState() {
    super.initState();
  }

  place() async {
    String orderId = Uuid().v4();
    DateTime tq = DateTime.now();
    oRders.document(orderId).setData({
      "orderId": orderId,
      "postId": post.postId,
      "item": post.item,
      "mediaUrl": post.mediaUrl,
      "userId": currentUser.id,
      "cost": (int.parse(post.cash) * t).toString(),
      "status": "Placed",
      "quantity": t,
      "timestamp": tq,
    });

    showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 3), () {
            Navigator.of(context).pop(true);
          });
          return AlertDialog(
            backgroundColor: Colors.white,
            title: new Text("Placing Order!!!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            content: Container(
              padding: EdgeInsets.only(bottom: 10.0),
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.black),
              ),
            ),
          );
        });

    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              backgroundColor: Colors.white,
              title: new Text("Order Placed!!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              // content:  Text("You gotta follow atleast one user to see the timeline.Find some users to follow.Don't be a loner dude!!!!",style:TextStyle(fontSize: 17, fontWeight: FontWeight.bold,color: Colors.white)),
            ));
  }

  int cost;
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
          post = Post.fromDocument(snapshot.data);
          cost = int.parse(post.cash);
          return Scaffold(
            backgroundColor: _getColorFromHex("#7338ac"),
            appBar: AppBar(
              leading: new IconButton(
                icon: new Icon(Icons.arrow_back_ios,
                    color: _getColorFromHex("#f0f4ff")),
                onPressed: () => Navigator.of(context).pop(),
              ),
              backgroundColor: _getColorFromHex("#7338ac"),
              elevation: 0,
              iconTheme: IconThemeData(
                color: Colors.white,
              ),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                      padding: EdgeInsets.all(32),
                      child: GestureDetector(
                        child: AspectRatio(
                            aspectRatio: 1 / 1,
                            child: CachedNetworkImage(
                              fit: BoxFit.fill,
                              imageUrl: post.mediaUrl,
                              placeholder: (context, url) => Padding(
                                child: CircularProgressIndicator(),
                                padding: EdgeInsets.all(4),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            )),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Img(url: post.mediaUrl),
                            ),
                          );
                        },
                      )),
                ),
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(100.0)),
                      child: Container(
                          color: _getColorFromHex("#f0f4ff"),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        child: Card(
                                          color: _getColorFromHex("#f0f4ff"),
                                          elevation: 0,
                                          child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.4,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: _getColorFromHex(
                                                        "#635ad9"),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20))),
                                              padding: EdgeInsets.all(4),
                                              alignment: Alignment.center,
                                              child: Text("${post.item}",
                                                  style: TextStyle(
                                                    fontFamily: "Poppins-Bold",
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.black,
                                                    fontSize: 20.0,
                                                  ),
                                                  textAlign: TextAlign.center)),
                                        ),
                                      ),
                                    ]),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      RichText(
                                        text: new TextSpan(
                                          children: [
                                            new TextSpan(
                                              text: 'If you wanna see more ',
                                              style: new TextStyle(
                                                  fontFamily: "Poppins-Regular",
                                                  color: Colors.black),
                                            ),
                                            new TextSpan(
                                              text: 'click here',
                                              style: new TextStyle(
                                                  fontFamily: "Poppins-Regular",
                                                  color: Colors.blue),
                                              recognizer:
                                                  new TapGestureRecognizer()
                                                    ..onTap = () {
                                                      launch(post.link);
                                                    },
                                            ),
                                            new TextSpan(
                                              text: ' !!!',
                                              style: new TextStyle(
                                                  fontFamily: "Poppins-Regular",
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      )
                                    ]),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text("${post.description}",
                                          style: TextStyle(
                                            fontFamily: "Poppins-Regular",
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                            fontSize: 18.0,
                                          ),
                                          textAlign: TextAlign.center)
                                    ]),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text("₹ $cost",
                                          style: TextStyle(
                                            fontFamily: "Poppins-Regular",
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                            fontSize: 18.0,
                                          ),
                                          textAlign: TextAlign.center)
                                    ]),
                                (sEller != currentUser.id &&
                                        sEller1 != currentUser.id)
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                            Text("     QUANTITY : ",
                                                style: TextStyle(
                                                  fontFamily: "Poppins-Regular",
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                  fontSize: 15.0,
                                                )),
                                            ClipOval(
                                              child: Material(
                                                color: Colors
                                                    .transparent, // button color
                                                child: InkWell(
                                                  // inkwell color
                                                  child: SizedBox(
                                                    child: Icon(
                                                      Icons
                                                          .remove_circle_outline,
                                                      size: 20,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    setState(() {
                                                      if (t > 1) {
                                                        t = t - 1;
                                                      } else
                                                        showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              Future.delayed(
                                                                  Duration(
                                                                      seconds:
                                                                          1),
                                                                  () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(true);
                                                              });
                                                              return AlertDialog(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                title: new Text(
                                                                    "Qty must be atleast 1!!",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          "Poppins-Regular",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          15.0,
                                                                    )),
                                                              );
                                                            });
                                                      cost = cost * t;
                                                      print(cost);
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                            Text("$t          ",
                                                style: TextStyle(
                                                  fontFamily: "Poppins-Regular",
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                  fontSize: 15.0,
                                                ),
                                                textAlign: TextAlign.center),
                                            ClipOval(
                                              child: Material(
                                                color: Colors
                                                    .transparent, // button color
                                                child: InkWell(
                                                  // inkwell color
                                                  child: SizedBox(
                                                    child: Icon(
                                                      Icons.add_circle_outline,
                                                      size: 20,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    setState(() {
                                                      t = t + 1;
                                                    });

                                                    setState(() {
                                                      cost = cost * t;

                                                      print(cost);
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ])
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (_) => new AlertDialog(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                title: new Text(
                                                                    "Are you sure??",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20.0,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .black)),
                                                                content: new Text(
                                                                    "Click yes to delete item",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15.0,
                                                                        color: Colors
                                                                            .black)),
                                                                actions: [
                                                                  FlatButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);

                                                                        postsRef
                                                                            .document(sEller)
                                                                            .collection("userPosts")
                                                                            .document(post.postId)
                                                                            .get()
                                                                            .then((doc) {
                                                                          if (doc
                                                                              .exists) {
                                                                            doc.reference.delete();
                                                                          }
                                                                        });

                                                                        showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (context) {
                                                                              Future.delayed(Duration(seconds: 3), () {
                                                                                Navigator.of(context).pop(true);
                                                                                Navigator.pop(context);
                                                                                showDialog(
                                                                                    context: context,
                                                                                    builder: (_) => new AlertDialog(
                                                                                          backgroundColor: Colors.white,
                                                                                          title: new Text("Item Deleted!!!", textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black)),
                                                                                        ));
                                                                              });
                                                                              return AlertDialog(
                                                                                backgroundColor: Colors.white,
                                                                                title: new Text("Deleting Item!!!", textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black)),
                                                                                content: Container(
                                                                                  padding: EdgeInsets.only(bottom: 10.0),
                                                                                  child: LinearProgressIndicator(
                                                                                    valueColor: AlwaysStoppedAnimation(Colors.black),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            });
                                                                      },
                                                                      child: Text(
                                                                          "Yes",
                                                                          style: TextStyle(
                                                                              fontSize: 15.0,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.blue))),
                                                                  FlatButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: Text(
                                                                          "No",
                                                                          style: TextStyle(
                                                                              fontSize: 15.0,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.blue))),
                                                                  FlatButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: Text(
                                                                          "Cancel",
                                                                          style: TextStyle(
                                                                              fontSize: 15.0,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.blue)))
                                                                ]));
                                              },
                                              child: Image(
                                                image: AssetImage(
                                                    'images/trash-can.png'),
                                                width: 32,
                                                height: 32,
                                              ),
                                            ),
                                          ]),
                                (sEller != currentUser.id &&
                                        sEller1 != currentUser.id)
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                            Container(
                                              child: Card(
                                                color:
                                                    _getColorFromHex("#88f4ff"),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0)),
                                                elevation: 0,
                                                child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                    height: 35,
                                                    padding: EdgeInsets.all(4),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "Add to cart",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            "Poppins-Regular",
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black,
                                                        fontSize: 15.0,
                                                      ),
                                                    )),
                                              ),
                                            ),
                                            Container(
                                              child: Card(
                                                color:
                                                    _getColorFromHex("#88f4ff"),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0)),
                                                elevation: 0,
                                                child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Place(
                                                                  post: post,
                                                                  t: t),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                        height: 35,
                                                        padding:
                                                            EdgeInsets.all(4),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          "Buy Now",
                                                          style: TextStyle(
                                                            fontFamily:
                                                                "Poppins-Regular",
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.black,
                                                            fontSize: 15.0,
                                                          ),
                                                        ))),
                                              ),
                                            ),
                                          ])
                                    : Text(""),
                                (sEller != currentUser.id &&
                                        sEller1 != currentUser.id)
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                            Container(
                                              child: Card(
                                                color:
                                                    _getColorFromHex("#88f4ff"),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0)),
                                                elevation: 0,
                                                child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                    height: 35,
                                                    padding: EdgeInsets.all(4),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "Customization",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            "Poppins-Regular",
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black,
                                                        fontSize: 15.0,
                                                      ),
                                                    )),
                                              ),
                                            ),
                                          ])
                                    : Text(""),
                              ]))),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

Color _getColorFromHex(String hexColor) {
  hexColor = hexColor.replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  if (hexColor.length == 8) {
    return Color(int.parse("0x$hexColor"));
  }
}
