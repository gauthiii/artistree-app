import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:Artis_Tree/models/Rev.dart';
import 'package:Artis_Tree/pages/Reviews.dart';
import 'package:Artis_Tree/pages/progress.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:Artis_Tree/models/tile_builder.dart';
import 'package:Artis_Tree/pages/home.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:convert';

import 'package:uuid/uuid.dart';

class Post extends StatefulWidget {
  final String cash;
  final String description;
  final String item;
  final String mediaUrl;
  final String postId;
  final String seller;
  final String category;
  final String link;
  final bool isBought;
  final Timestamp timestamp;

  Post(
      {this.cash,
      this.description,
      this.item,
      this.mediaUrl,
      this.postId,
      this.link,
      this.category,
      this.isBought,
      this.seller,
      this.timestamp});

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
        cash: doc['cash'],
        description: doc['description'],
        item: doc['item'],
        mediaUrl: doc['mediaUrl'],
        postId: doc['postId'],
        category: doc['category'],
        link: doc['link'],
        isBought: doc['isBought'],
        seller: doc['seller'],
        timestamp: doc['timestamp']);
  }

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  String rstate = "inactive";

  @override
  void initState() {
    super.initState();
    getRev();
  }

  getRev() async {
    DocumentSnapshot doc = await rRef.document(widget.postId).get();

    Fid fidx = Fid.fromDocument(doc);

    int flag = 0;

    for (int i = 0; i < fidx.fid.length; i++)
      if (fidx.fid[i].split("-")[1] == currentUser.id) {
        flag = 1;
        for (int j = 0; j < int.parse(fidx.fid[i].split("-")[0][0]); j++) {
          setState(() {
            stars = fidx.fid[i].split("-")[0][0] + "/5";
            isTapped[j] = true;
          });
        }
        break;
      }
    if (flag == 1)
      setState(() {
        rstate = "error";
      });
  }

  buildPostHeader() {
    return ListTile(
      leading: CircleAvatar(
        child: Icon(Icons.account_circle, color: Colors.black, size: 50),
        backgroundColor: Colors.pink[100],
      ),
      title: GestureDetector(
        onTap: () {},
        child: Text(
          widget.item,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      subtitle: Text(
        "Sold by " + widget.seller,
        style: TextStyle(color: Colors.black),
      ),
      trailing: IconButton(
        onPressed: () => handleDeletePost(context),
        icon: Icon(
          Icons.more_vert,
          color: Colors.black,
        ),
      ),
    );
  }

  handleDeletePost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          var height = MediaQuery.of(context).size.height;
          return AlertDialog(
            backgroundColor: Colors.white,
            title: new Text("Options",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            content: GestureDetector(
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Reviews(
                              postId: widget.postId,
                              mediaUrl: widget.mediaUrl,
                              seller: widget.seller,
                              item: widget.item,
                            )));
              },
              child: Container(
                  height: height * 0.05,
                  child: Center(
                      child: Text(
                    'Customer reviews',
                    style: TextStyle(color: Colors.blue),
                  ))),
            ),
          );
        });
  }

  image() {
    return Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(70.0)),
        color: Colors.pink[100],
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(70.0)),
          child: cachedNetworkImage(widget.mediaUrl),
        ));
  }

  price() {
    return ListTile(
      leading: Text(
        "MRP : ₹ ${widget.cash}",
        style: TextStyle(
            color: Colors.black, fontSize: 25, fontFamily: "FredokaOne"),
      ),
    );
  }

  List isTapped = [false, false, false, false, false];
  String stars = "0/5";

  rating() {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10),
        ),
        GestureDetector(
            onTap: () {
              setState(() {
                stars = "1/5";
                isTapped[4] = false;
                isTapped[3] = false;
                isTapped[2] = false;
                isTapped[1] = false;
                isTapped[0] = true;
              });
            },
            child: (isTapped[0] == false)
                ? Icon(Icons.star_border, color: Colors.black, size: 35)
                : Icon(Icons.star, color: Colors.black, size: 35)),
        GestureDetector(
            onTap: () {
              setState(() {
                stars = "2/5";
                isTapped[4] = false;
                isTapped[3] = false;
                isTapped[2] = false;
                isTapped[1] = true;
                isTapped[0] = true;
              });
            },
            child: (isTapped[1] == false)
                ? Icon(Icons.star_border, color: Colors.black, size: 35)
                : Icon(Icons.star, color: Colors.black, size: 35)),
        GestureDetector(
            onTap: () {
              setState(() {
                stars = "3/5";
                isTapped[4] = false;
                isTapped[3] = false;
                isTapped[2] = true;
                isTapped[1] = true;
                isTapped[0] = true;
              });
            },
            child: (isTapped[2] == false)
                ? Icon(Icons.star_border, color: Colors.black, size: 35)
                : Icon(Icons.star, color: Colors.black, size: 35)),
        GestureDetector(
            onTap: () {
              setState(() {
                stars = "4/5";
                isTapped[4] = false;
                isTapped[3] = true;
                isTapped[2] = true;
                isTapped[1] = true;
                isTapped[0] = true;
              });
            },
            child: (isTapped[3] == false)
                ? Icon(Icons.star_border, color: Colors.black, size: 35)
                : Icon(Icons.star, color: Colors.black, size: 35)),
        GestureDetector(
            onTap: () {
              setState(() {
                stars = "5/5";
                isTapped[4] = true;
                isTapped[3] = true;
                isTapped[2] = true;
                isTapped[1] = true;
                isTapped[0] = true;
              });
            },
            child: (isTapped[4] == false)
                ? Icon(Icons.star_border, color: Colors.black, size: 35)
                : Icon(Icons.star, color: Colors.black, size: 35)),
        Padding(
          padding: EdgeInsets.only(left: 10),
        ),
        Text(stars,
            style: TextStyle(
                color: Colors.black, fontSize: 25, fontFamily: "FredokaOne")),
        Padding(
          padding: EdgeInsets.only(left: 15),
        ),
        RaisedButton.icon(
            color: Colors.black,
            onPressed: () {
              add();
            },
            icon: icon(),
            label: Text("")),
      ],
    );
  }

  icon() {
    if (rstate == "inactive")
      return Text("Submit Review");
    else if (rstate == "loading")
      return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 10.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ));
    else if (rstate == "submitted")
      return Text("Submitted!!!");
    else if (rstate == "error")
      return Text("Already Submitted");
    else
      return Text("");
  }

  List<String> f = [];
  Fid fid;
  add() async {
    setState(() {
      rstate = "loading";
    });
    DocumentSnapshot doc = await rRef.document(widget.postId).get();

    if (!doc.exists) {
      setState(() {
        f.add(stars + "-" + currentUser.id);
      });

      rRef.document(widget.postId).setData({"Ids": FieldValue.arrayUnion(f)});
      setState(() {
        rstate = "submitted";
      });
    } else {
      fid = Fid.fromDocument(doc);

      int flag = 0;

      for (int i = 0; i < fid.fid.length; i++)
        if (fid.fid[i].split("-")[1] == currentUser.id) {
          flag = 1;
          break;
        }
      if (flag == 0) {
        setState(() {
          fid.fid.add(stars + "-" + currentUser.id);
        });

        rRef
            .document(widget.postId)
            .setData({"Ids": FieldValue.arrayUnion(fid.fid)});
        setState(() {
          rstate = "submitted";
        });
      } else {
        print("already done");
        setState(() {
          rstate = "error";
        });
      }
    }
  }

  desc() {
    return Padding(
        padding: EdgeInsets.only(left: 24, right: 24),
        child: Card(
          elevation: 5.0,
          color: Colors.red[300],
          child: Container(
            height: 65 * (widget.description.length / 18),
            child: Center(
              child: Text(widget.description,
                  style: TextStyle(
                      fontFamily: "Bangers",
                      fontWeight: FontWeight.bold,
                      fontSize: 30.0,
                      color: Colors.black)),
            ),
          ),
        ));
  }

  link() {
    return RichText(
      text: new TextSpan(
        children: [
          new TextSpan(
            text: 'If you wanna see more ',
            style: new TextStyle(color: Colors.black),
          ),
          new TextSpan(
            text: 'click here',
            style: new TextStyle(color: Colors.blue),
            recognizer: new TapGestureRecognizer()
              ..onTap = () {
                launch(widget.link);
              },
          ),
          new TextSpan(
            text: ' !!!',
            style: new TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }

  time() {
    List mon = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    DateTime ts = DateTime.now();
    DateTime ns = new DateTime(ts.year, ts.month, ts.day + 6);
    String x = ns.toString();

    x = x.split(" ")[0];
    String y = x.substring(x.length - 2) +
        " " +
        mon[ns.month - 1] +
        " [ 5-6 Business Days]";
    return Text("Delivery : " + y,
        style: TextStyle(
            color: Colors.black, fontSize: 20, fontFamily: "FredokaOne"));
  }

  fun() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              backgroundColor: Colors.white,
              title: new Text("ORDER     PLACED!!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "JustAnotherHand",
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              // content:  Text("You gotta follow atleast one user to see the timeline.Find some users to follow.Don't be a loner dude!!!!",style:TextStyle(fontSize: 17, fontWeight: FontWeight.bold,color: Colors.white)),
            ));
  }

  place() async {
    String orderId = Uuid().v4();
    DateTime tq = DateTime.now();
    oRders.document(orderId).setData({
      "orderId": orderId,
      "postId": widget.postId,
      "item": widget.item,
      "mediaUrl": widget.mediaUrl,
      "userId": currentUser.id,
      "cost": (int.parse(widget.cash) * t).toString(),
      "status": "Placed",
      "quantity": t,
      "timestamp": tq,
    });

    showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 3), () {
            Navigator.of(context).pop(true);
            fun();
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
  }

  int t = 1;
  quant() {
    return Row(children: [
      Expanded(
        flex: 3,
        child: Text("     QUANTITY : ",
            style: TextStyle(
                fontFamily: 'Bangers',
                fontSize: 36.0,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      ),
      Expanded(
        flex: 1,
        child: ClipOval(
          child: Material(
            color: Colors.transparent, // button color
            child: InkWell(
              // inkwell color
              child: SizedBox(
                child: Icon(
                  Icons.remove_circle_outline,
                  size: 36,
                  color: Colors.black,
                ),
              ),
              onTap: () {
                setState(() {
                  if (t > 1)
                    t = t - 1;
                  else
                    showDialog(
                        context: context,
                        builder: (context) {
                          Future.delayed(Duration(seconds: 1), () {
                            Navigator.of(context).pop(true);
                          });
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            title: new Text("Qty must be atleast 1!!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                          );
                        });
                });
              },
            ),
          ),
        ),
      ),
      Expanded(
          flex: 1,
          child: Text("$t",
              style: TextStyle(
                  fontFamily: 'Bangers',
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              textAlign: TextAlign.center)),
      Expanded(
        flex: 1,
        child: ClipOval(
          child: Material(
            color: Colors.transparent, // button color
            child: InkWell(
              // inkwell color
              child: SizedBox(
                child: Icon(
                  Icons.add_circle_outline,
                  size: 36,
                  color: Colors.black,
                ),
              ),
              onTap: () {
                setState(() {
                  t = t + 1;
                });
              },
            ),
          ),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        buildPostHeader(),
        image(),
        Divider(),
        price(),
        rating(),
        Divider(),
        desc(),
        Divider(),
        time(),
        Divider(),
        link(),
        Divider(),
        quant(),
        Divider(),
        Container(
          alignment: Alignment.center,
          child: RaisedButton(
            color: Colors.black,
            onPressed: place,
            child:
                Text("\n                    Order Item                    \n"),
          ),
        )
      ],
    );
  }
}
