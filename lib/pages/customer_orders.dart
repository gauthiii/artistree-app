import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Artis_Tree/models/Rev.dart';
import 'package:Artis_Tree/models/order.dart';
import 'package:Artis_Tree/models/post.dart';
import 'package:Artis_Tree/models/tile_builder.dart';
import 'package:Artis_Tree/models/user.dart';
import 'package:Artis_Tree/pages/home.dart';
import 'package:Artis_Tree/pages/post_screen.dart';
import 'package:Artis_Tree/pages/progress.dart';

import 'adminOrder_reciept.dart';

class Corders extends StatefulWidget {
  final User currentUser;
  final String screen;
  Corders({this.currentUser, this.screen});
  @override
  Cx createState() => Cx();
}

class Cx extends State<Corders> {
  bool isloading = false;
  @override
  void initState() {
    super.initState();

    orders();
  }

  List<Order> morder = [];
  List<Order> order = [];

  orders() async {
    setState(() {
      morder = [];
      order = [];
      isloading = true;
    });
    print(widget.currentUser.id);
    QuerySnapshot snapshot =
        await oRders.orderBy('timestamp', descending: true).getDocuments();

    setState(() {
      isloading = false;
      morder =
          snapshot.documents.map((doc) => Order.fromDocument(doc)).toList();
    });
    print(morder.length);
    morder.forEach((element) {
      setState(() {
        //  if (element.userId != widget.currentUser.id) order.remove(element);
        if (element.userId == widget.currentUser.id) order.add(element);
      });
    });
    print(order.length);
  }

  fun() {
    Navigator.pop(context);
    Navigator.pop(context);

    orders();

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
    if (isloading == true)
      return Scaffold(
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(100.0), // here the desired height
              child: AppBar(
                  leading: new IconButton(
                    icon: new Icon(Icons.arrow_back_ios,
                        color: _getColorFromHex("#635ad9")),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  elevation: 0,
                  backgroundColor: _getColorFromHex("#f0f4ff"),
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              padding: EdgeInsets.all(4),
                              alignment: Alignment.center,
                              child: Text("Orders",
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
                  ))),
          backgroundColor: _getColorFromHex("#f0f4ff"),
          body: Center(child: circularProgress()));
    else if (order.length == 0)
      return Scaffold(
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(100.0), // here the desired height
              child: AppBar(
                  leading: new IconButton(
                    icon: new Icon(Icons.arrow_back_ios,
                        color: _getColorFromHex("#635ad9")),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  elevation: 0,
                  backgroundColor: _getColorFromHex("#f0f4ff"),
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              padding: EdgeInsets.all(4),
                              alignment: Alignment.center,
                              child: Text("Orders",
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
                  ))),
          backgroundColor: _getColorFromHex("#f0f4ff"),
          body: RefreshIndicator(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.error_outline,
                      size: 250,
                      color: Colors.black,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text(
                        "NO ORDERS !!!!",
                        style: TextStyle(
                          fontFamily: "Bangers",
                          color: Colors.black,
                          fontSize: 60.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ignore: missing_return
              onRefresh: () {
                orders();
              }));
    else
      return Scaffold(
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(80.0), // here the desired height
              child: AppBar(
                  leading: new IconButton(
                    icon: new Icon(Icons.arrow_back_ios,
                        size: 30, color: _getColorFromHex("#635ad9")),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  elevation: 0,
                  backgroundColor: _getColorFromHex("#f0f4ff"),
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              padding: EdgeInsets.all(4),
                              alignment: Alignment.center,
                              child: Text("Orders",
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
                  ))),
          backgroundColor: _getColorFromHex("#f0f4ff"),
          body: orders_list());
  }

  // ignore: non_constant_identifier_names
  orders_list() {
    return RefreshIndicator(
        child: Expanded(
            child: ListView.separated(
          itemCount: order.length,
          separatorBuilder: (BuildContext context, int index) => Divider(),
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () async {
                print(widget.screen);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AReciept(
                      order: order[index],
                      screen: widget.screen,
                    ),
                  ),
                );
              },
              child: Stack(children: [
                Container(
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    color: _getColorFromHex("#635ad9").withOpacity(0.4),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: AspectRatio(
                                      aspectRatio: 4 / 5,
                                      child: CachedNetworkImage(
                                        fit: BoxFit.fill,
                                        imageUrl: order[index].mediaUrl,
                                        placeholder: (context, url) => Padding(
                                          child: CircularProgressIndicator(),
                                          padding: EdgeInsets.all(4),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ))),
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("${order[index].item}\n",
                                      style: TextStyle(
                                        fontFamily: "Poppins-Regular",
                                        color: Colors.black,
                                        fontSize: 13.0,
                                      )),
                                  Text("Qty : ${order[index].quantity}\n",
                                      style: TextStyle(
                                        fontFamily: "Poppins-Regular",
                                        color: Colors.black,
                                        fontSize: 13.0,
                                      )),
                                  Text("Price : ${order[index].cost} Rs\n",
                                      style: TextStyle(
                                        fontFamily: "Poppins-Regular",
                                        color: Colors.black,
                                        fontSize: 13.0,
                                      )),
                                  Text("Customized",
                                      style: TextStyle(
                                        fontFamily: "Poppins-Regular",
                                        color: Colors.black,
                                        fontSize: 13.0,
                                      )),
                                ],
                              )),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text("\n\n\n\n\n\n\n",
                                      style: TextStyle(
                                        fontFamily: "Poppins-Regular",
                                        color: Colors.black,
                                        fontSize: 12.0,
                                      )),
                                  Text(
                                      "Delivered By : ${delivery(order[index].timestamp.toDate()).substring(0, 6)}",
                                      style: TextStyle(
                                        fontFamily: "Poppins-Regular",
                                        color: Colors.black,
                                        fontSize: 11,
                                      )),
                                ],
                              )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(""),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(""),
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("\n\n",
                                    style: TextStyle(
                                      fontFamily: "Poppins-Regular",
                                      color: Colors.black,
                                      fontSize: 12.0,
                                    )),
                                Container(
                                  width: 150,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: (order[index].status ==
                                                  "Cancelled")
                                              ? Colors.red[900]
                                              : Colors.green[900],
                                          width: 2.0),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15))),
                                  alignment: Alignment.center,
                                  child: Text(order[index].status,
                                      style: TextStyle(
                                        fontFamily: "Poppins-Bold",
                                        fontWeight: FontWeight.w900,
                                        color:
                                            (order[index].status == "Cancelled")
                                                ? Colors.red[900]
                                                : Colors.green[900],
                                        fontSize: 15.0,
                                      ),
                                      textAlign: TextAlign.center),
                                ),
                                Text("\n",
                                    style: TextStyle(
                                      fontFamily: "Poppins-Regular",
                                      color: Colors.black,
                                      fontSize: 12.0,
                                    )),
                              ],
                            )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            );
          },
        )),
        // ignore: missing_return
        onRefresh: () {
          orders();
        });
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
  String y = x.substring(x.length - 2) +
      " " +
      mon[ns.month - 1] +
      " " +
      ns.year.toString();
  return y;
}

time(DateTime ns) {
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

  String x = ns.toString();

  x = x.split(" ")[0];
  String y = x.substring(x.length - 2) +
      " " +
      mon[ns.month - 1] +
      " " +
      x.substring(0, 4);
  return y;
}

am(String x) {
  String y = x.substring(0, 2);
  int y1 = int.parse(y);

  if (y1 == 0)
    return "12" + x.substring(2) + " AM";
  else if (y1 < 12)
    return y1.toString() + x.substring(2) + " AM";
  else if (y1 == 12)
    return "12" + x.substring(2) + " PM";
  else
    return (y1 - 12).toString() + x.substring(2) + " PM";
}

// ignore: missing_return
Color _getColorFromHex(String hexColor) {
  hexColor = hexColor.replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  if (hexColor.length == 8) {
    return Color(int.parse("0x$hexColor"));
  }
}
