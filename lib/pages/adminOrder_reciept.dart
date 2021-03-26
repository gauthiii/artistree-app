import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:Artis_Tree/models/order.dart';
import 'package:Artis_Tree/models/post.dart';
import 'package:Artis_Tree/models/user.dart';
import 'package:Artis_Tree/pages/progress.dart';
import 'package:uuid/uuid.dart';

import 'home.dart';

class AReciept extends StatefulWidget {
  final Order order;
  final String screen;

  AReciept({this.order, this.screen});

  @override
  Cx createState() => Cx();
}

class Cx extends State<AReciept> {
  bool isloading = false;
  User user;
  Post post;
  @override
  void initState() {
    super.initState();

    receipt();
  }

  receipt() async {
    setState(() {
      isloading = true;
    });

    print(widget.order.userId);

    if (currentUser.id == sEller || currentUser.id == sEller1) {
      DocumentSnapshot doc = await usersRef.document(widget.order.userId).get();
      user = User.fromDocument(doc);
    } else {
      DocumentSnapshot doc = await usersRef.document(sEller).get();
      user = User.fromDocument(doc);
    }

    DocumentSnapshot doc1 = await postsRef
        .document(sEller)
        .collection("userPosts")
        .document(widget.order.postId)
        .get();
    post = Post.fromDocument(doc1);
    setState(() {
      isloading = false;
    });
  }

  fun() {
    if (widget.screen == "home") {
      Navigator.pop(context);
      Navigator.pop(context);
    } else if (widget.screen == "drawer") {
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
    }

    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              backgroundColor: Colors.white,
              title: new Text("Order Cancelled!!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: _getColorFromHex("#f0f4ff"),
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios,
                color: _getColorFromHex("#635ad9")),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                child: Card(
                  color: _getColorFromHex("#f0f4ff"),
                  elevation: 0,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: _getColorFromHex("#635ad9"),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      padding: EdgeInsets.all(4),
                      alignment: Alignment.center,
                      child: Text("Order Reciept",
                          style: TextStyle(
                            fontFamily: "Poppins-Bold",
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            fontSize: 20.0,
                          ),
                          textAlign: TextAlign.center)),
                ),
              ),
            ],
          )),
      backgroundColor: _getColorFromHex("#f0f4ff"),
      body: (isloading == true)
          ? circularProgress()
          : Container(
              color: _getColorFromHex("#f0f4ff"),
              child: ListView(children: [
                ListTile(
                    leading: Icon(
                      Icons.description,
                      color: Colors.black,
                      size: 35.0,
                    ),
                    title: Text("Order ID",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    subtitle: Text("${widget.order.orderId}",
                        style: TextStyle(
                          color: Colors.black,
                        ))),
                ListTile(
                    leading: Icon(
                      Icons.account_circle,
                      color: Colors.black,
                      size: 35.0,
                    ),
                    title: Text(
                        "${post.item}  (Qty : ${widget.order.quantity})",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    subtitle: Text("Sold by ${post.seller}",
                        style: TextStyle(
                          color: Colors.black,
                        ))),
                ListTile(
                    leading: Text(" ₹",
                        style: TextStyle(color: Colors.black, fontSize: 35)),
                    title: Text("Amount",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    subtitle: Text("${widget.order.cost} ",
                        style: TextStyle(
                          color: Colors.black,
                        ))),
                ListTile(
                    trailing: Container(
                      width: 150,
                      height: 50,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: (widget.order.status == "Cancelled")
                                  ? Colors.red[900]
                                  : Colors.green[900],
                              width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      alignment: Alignment.center,
                      child: Text(widget.order.status,
                          style: TextStyle(
                            fontFamily: "Poppins-Bold",
                            fontWeight: FontWeight.w900,
                            color: (widget.order.status == "Cancelled")
                                ? Colors.red[900]
                                : Colors.green[900],
                            fontSize: 15.0,
                          ),
                          textAlign: TextAlign.center),
                    ),
                    leading: Icon(
                      Icons.present_to_all,
                      color: Colors.black,
                      size: 35.0,
                    ),
                    title: Text("Expected Delivery",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    subtitle: Text(delivery(widget.order.timestamp.toDate()),
                        style: TextStyle(
                          color: Colors.black,
                        ))),
                Divider(),
                Center(
                    child: Text(
                        (currentUser.id == sEller || currentUser.id == sEller1)
                            ? "Customer Details"
                            : "Seller Details",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20))),
                Divider(),
                ClipRRect(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(100),
                      bottomRight: Radius.circular(100),
                    ),
                    child: Container(
                        padding: EdgeInsets.all(20),
                        width: MediaQuery.of(context).size.width,
                        color: _getColorFromHex("#7338ac"),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                child: Center(
                                  child: CircleAvatar(
                                    radius: 35,
                                    backgroundColor:
                                        _getColorFromHex("#f0f4ff"),
                                    child: Text("${user.displayName[0]}",
                                        style: TextStyle(
                                            fontSize: 45,
                                            fontWeight: FontWeight.w700,
                                            color: _getColorFromHex("#7338ac"),
                                            fontFamily: "Poppins-Bold")),
                                  ),
                                ),
                                flex: 1),
                            Expanded(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("${user.displayName}",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  _getColorFromHex("#f0f4ff"),
                                              fontFamily: "Poppins-Bold")),
                                      Text("+91-${user.mobile}",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  _getColorFromHex("#f0f4ff"),
                                              fontFamily: "Poppins-Bold")),
                                      Text("${user.email}",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  _getColorFromHex("#f0f4ff"),
                                              fontFamily: "Poppins-Bold")),
                                    ]),
                                flex: 3)
                          ],
                        ))),
                Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(16),
                      alignment: Alignment.topLeft,
                      height: 150,
                      child: Text(
                          "\nBilling Address :\n${user.door},\n${user.street},\n${user.locality},\n${user.city}-${user.zip}",
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontFamily: "Poppins-Regular")),
                    ),
                  ],
                ),
                GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.6,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      RaisedButton(
                        color: Colors.indigo[50],
                        elevation: 1,
                        onPressed: () {
                          FlutterOpenWhatsapp.sendSingleMessage(
                              "91${user.mobile}", "Hello");
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image(
                              image: AssetImage('images/whatsapp.png'),
                              width: 64,
                              height: 64,
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 4),
                              child: Text("Text on Whatsapp",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins-Regular")),
                            ),
                          ],
                        ),
                      ),
                      RaisedButton(
                        color: Colors.indigo[50],
                        elevation: 1,
                        onPressed: () {
                          if (widget.order.status == "Delivered")
                            showDialog(
                                context: context,
                                builder: (_) => new AlertDialog(
                                      backgroundColor: Colors.white,
                                      title: new Text("Already Delivered!!!",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)),
                                    ));
                          else
                            showDialog(
                                context: context,
                                builder: (_) => new AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: new Text("Are you sure??",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black)),
                                        content: new Text(
                                            (widget.order.status == "Cancelled")
                                                ? "Click yes to delete order"
                                                : "Click yes to cancel order",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 15.0,
                                                color: Colors.black)),
                                        actions: [
                                          FlatButton(
                                              onPressed: () {
                                                Navigator.pop(context);

                                                oRders
                                                    .document(
                                                        widget.order.orderId)
                                                    .get()
                                                    .then((doc) {
                                                  if (doc.exists) {
                                                    doc.reference.delete();
                                                  }
                                                });

                                                /*   activityFeedRef
                                                  .document(sEller)
                                                  .collection('feedItems')
                                                  .document(
                                                      widget.order.orderId)
                                                  .get()
                                                  .then((doc) {
                                                if (doc.exists) {
                                                  doc.reference.delete();
                                                }
                                              });*/

                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      Future.delayed(
                                                          Duration(seconds: 3),
                                                          () {
                                                        Navigator.of(context)
                                                            .pop(true);
                                                        fun();
                                                      });
                                                      return AlertDialog(
                                                        backgroundColor:
                                                            Colors.white,
                                                        title: new Text(
                                                            (widget.order
                                                                        .status ==
                                                                    "Cancelled")
                                                                ? "Deleting Order!!!"
                                                                : "Cancelling Order!!!",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 20.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black)),
                                                        content: Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  bottom: 10.0),
                                                          child:
                                                              LinearProgressIndicator(
                                                            valueColor:
                                                                AlwaysStoppedAnimation(
                                                                    Colors
                                                                        .black),
                                                          ),
                                                        ),
                                                      );
                                                    });
                                              },
                                              child: Text("Yes",
                                                  style: TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue))),
                                          FlatButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text("No",
                                                  style: TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue))),
                                          FlatButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text("Cancel",
                                                  style: TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue)))
                                        ]));
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image(
                              image: AssetImage('images/close.png'),
                              width: 64,
                              height: 64,
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 4),
                              child: Text(
                                  (widget.order.status == "Cancelled")
                                      ? "Delete Order"
                                      : "Cancel Order",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins-Regular")),
                            ),
                          ],
                        ),
                      ),
                    ]),
              ])),
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

delivery(ts) {
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

  DateTime ns = new DateTime(ts.year, ts.month, ts.day + 6);
  String x = ns.toString();

  x = x.split(" ")[0];
  String y =
      x.substring(x.length - 2) + " " + mon[ns.month - 1] + " ${ns.year}";
  return y;
}
