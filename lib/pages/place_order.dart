import 'dart:math';

import 'package:Artis_Tree/models/order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Artis_Tree/models/post.dart';
import 'package:Artis_Tree/pages/home.dart';
import 'package:upi_pay/upi_pay.dart';
import 'package:uuid/uuid.dart';

class Place extends StatefulWidget {
  final Post post;
  final int t;

  Place({this.post, this.t});
  @override
  Cx createState() => Cx();
}

class Cx extends State<Place> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('ORDER CONFIRMATION',
            style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins-Regular")),
        centerTitle: true,
      ),
      backgroundColor: _getColorFromHex("#f0f4ff"),
      body: Screen(post: widget.post, t: widget.t),
    );
  }
}

class Screen extends StatefulWidget {
  final Post post;
  final int t;

  Screen({this.post, this.t});
  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  String _upiAddrError;

  final _upiAddressController = TextEditingController();
  final _amountController = TextEditingController();

  Future<List<ApplicationMeta>> _appsFuture;

  place() async {
    Navigator.pop(context);
    Navigator.pop(context);
    String orderId = Uuid().v4();
    DateTime tq = DateTime.now();
    oRders.document(orderId).setData({
      "orderId": orderId,
      "postId": widget.post.postId,
      "item": widget.post.item,
      "mediaUrl": widget.post.mediaUrl,
      "userId": currentUser.id,
      "cost": (int.parse(widget.post.cash) * widget.t).toString(),
      "status": "Order Placed",
      "quantity": widget.t,
      "timestamp": tq,
      "cus": currentUser.displayName,
      "cnotif": FieldValue.arrayUnion([]),
      "anotif": FieldValue.arrayUnion([]),
    });

    activityFeedRef
        .document(sEller)
        .collection('feedItems')
        .document(orderId)
        .setData({
      "notifId": currentUser.id,
      "feedId": orderId,
      "mediaUrl": widget.post.mediaUrl,
      "orderId": orderId,
      "cus": currentUser.displayName,
      "timestamp": tq,
      "status": "Order Placed",
    });

    String feedId = Uuid().v4();

    activityFeedRef
        .document(currentUser.id)
        .collection('feedItems')
        .document(feedId)
        .setData({
      "notifId": currentUser.id,
      "feedId": feedId,
      "mediaUrl": widget.post.mediaUrl,
      "orderId": orderId,
      "cus": currentUser.displayName,
      "timestamp": tq,
      "status": "Order Placed",
    });

    {
      DocumentSnapshot doc = await oRders.document(orderId).get();

      Order order = Order.fromDocument(doc);

      setState(() {
        order.anotif.add(orderId);
        order.cnotif.add(feedId);
      });

      oRders.document(orderId).updateData({
        "anotif": FieldValue.arrayUnion(order.anotif),
        "cnotif": FieldValue.arrayUnion(order.cnotif)
      });
    }

    fun() {
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

  @override
  void initState() {
    super.initState();

    _upiAddressController.text = "jammi.roshan99@okhdfcbank";
    _amountController.text =
        (int.parse(widget.post.cash) * widget.t).toString();
    _appsFuture = UpiPay.getInstalledUpiApplications();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _upiAddressController.dispose();
    super.dispose();
  }

  Future<void> _onTap(ApplicationMeta app) async {
    final err = _validateUpiAddress(_upiAddressController.text);
    if (err != null) {
      setState(() {
        _upiAddrError = err;
      });
      return;
    }
    setState(() {
      _upiAddrError = null;
    });

    final transactionRef = Random.secure().nextInt(1 << 32).toString();
    print("Starting transaction with id $transactionRef");

    final a = await UpiPay.initiateTransaction(
      amount: _amountController.text,
      app: app.upiApplication,
      receiverName: 'Gautham',
      receiverUpiAddress: "yamini.vijayaraj.1972@oksbi",
      transactionRef: transactionRef,
    );

    print(a);
  }

  bool show = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        children: <Widget>[
          ListTile(
              leading: Icon(
                Icons.account_circle,
                color: Colors.black,
                size: 35.0,
              ),
              title: Text("${widget.post.item}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              trailing: Text("Qty : ${widget.t}\n",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              subtitle: Text("Sold by ${widget.post.seller}",
                  style: TextStyle(
                    color: Colors.black,
                  ))),
          ListTile(
              leading: Text(" ₹",
                  style: TextStyle(color: Colors.black, fontSize: 35)),
              title: Text("Amount",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              trailing: Text("${(int.parse(widget.post.cash) * widget.t)} ",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold))),
          Divider(),
          Center(
              child: Text('CHOOSE THE PAYMENT METHOD',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins-Regular"))),
          Container(
            margin: EdgeInsets.only(top: 8),
            child: RaisedButton(
                onPressed: () {
                  setState(() {
                    show = true;
                  });
                },
                color: Colors.black,
                child: Text("Pay using UPI",
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontFamily: "Poppins-Regular"))),
          ),
          if (_upiAddrError != null)
            Container(
              margin: EdgeInsets.only(top: 4, left: 12),
              child: Text(
                _upiAddrError,
                style: TextStyle(color: Colors.red),
              ),
            ),
          Container(
            margin: EdgeInsets.only(top: 32),
            child: RaisedButton(
                onPressed: place,
                color: Colors.black,
                child: Text("Cash on Delivery",
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontFamily: "Poppins-Regular"))),
          ),
          (show == true)
              ? Container(
                  margin: EdgeInsets.only(top: 32, bottom: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Pay Using',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontFamily: "Poppins-Regular"),
                        ),
                      ),
                      FutureBuilder<List<ApplicationMeta>>(
                        future: _appsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return Container();
                          }

                          return GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 1.6,
                            physics: NeverScrollableScrollPhysics(),
                            children: snapshot.data
                                .map((it) => Material(
                                      key: ObjectKey(it.upiApplication),
                                      color: _getColorFromHex("#f0f4ff"),
                                      child: InkWell(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (_) => new AlertDialog(
                                                  backgroundColor: Colors.white,
                                                  title: new Text(
                                                      "UPI Payment Disabled!!!",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 20.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black)),
                                                  content: new Text(
                                                      "Please Choose COD",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 15.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Colors.black))));
                                          //_onTap(it);
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Image.memory(
                                              it.icon,
                                              width: 64,
                                              height: 64,
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 4),
                                              child: Text(
                                                  it.upiApplication
                                                      .getAppName(),
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          "Poppins-Regular")),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ))
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                )
              : Text("")
        ],
      ),
    );
  }
}

String _validateUpiAddress(String value) {
  if (value.isEmpty) {
    return 'UPI Address is required.';
  }

  if (!UpiPay.checkIfUpiAddressIsValid(value)) {
    return 'UPI Address is invalid.';
  }

  return null;
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
