import 'package:Artis_Tree/models/feed.dart';
import 'package:Artis_Tree/pages/adminOrder_reciept.dart';
import 'package:Artis_Tree/pages/home.dart';
import 'package:Artis_Tree/pages/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class Notifs extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Notifs> {
  List<Feed> notif = [];
  String text = "";
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    n();
  }

  n() async {
    setState(() {
      isLoading = true;
    });
    notif = [];
    QuerySnapshot snapshot = await activityFeedRef
        .document(currentUser.id)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .getDocuments();

    snapshot.documents.forEach((doc) {
      notif.add(Feed.fromDocument(doc));
      // print('Activity Feed Item: ${doc.data}');
    });
    setState(() {
      isLoading = false;
    });
  }

  delete(String x, String y) {
    if (x == "Order Placed")
      text = ' placed an order';
    else if (x == "Order Confirmed")
      text = ' : order has been confirmed';
    else if (x == "Dispatched")
      text = ' : order has been confirmed';
    else if (x == "Delivering Today")
      text = ' : order will be delivered today';
    else if (x == "Delivered")
      text = ' received their order';
    else if (x == "Cancelled") text = ' cancelled their order';

    return text;
  }

  delete1(String x, String y) {
    if (x == "Order Placed")
      text = 'You placed an order';
    else if (x == "Order Confirmed")
      text = 'Your order has been confirmed';
    else if (x == "Dispatched")
      text = 'Your order has been dispatched';
    else if (x == "Delivering Today")
      text = 'Your order will be delivered today';
    else if (x == "Delivered")
      text = 'Your order has been delivered';
    else if (x == "Cancelled") text = 'Your order has been cancelled';

    return text;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading == true)
      return circularProgress();
    else if (notif.length == 0)
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.notifications_off,
            size: 250,
            color: _getColorFromHex("#7338ac"),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              "YOU DON'T HAVE ANY NOTIFICATIONS!!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _getColorFromHex("#7338ac"),
                fontFamily: "Bangers",
                fontSize: 50.0,
              ),
            ),
          ),
        ],
      );
    else
      return RefreshIndicator(
          child: ListView.separated(
            itemCount: notif.length,
            separatorBuilder: (BuildContext context, int index) => Divider(
              color: Colors.transparent,
              thickness: 0,
              height: 2.5,
            ),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                  onTap: () {},
                  onLongPress: () {
                    delete(notif[index].feedId, notif[index].notifId);
                    n();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 2.0),
                    child: Container(
                      color: _getColorFromHex("#7338ac").withOpacity(0.5),
                      child: ListTile(
                        title: RichText(
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: (currentUser.id == sEller)
                                      ? notif[index].cus
                                      : "",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins-Bold"),
                                ),
                                TextSpan(
                                  text: (currentUser.id == sEller)
                                      ? delete(notif[index].status,
                                          notif[index].notifId)
                                      : delete1(notif[index].status,
                                          notif[index].notifId),
                                  style:
                                      TextStyle(fontFamily: "Poppins-Regular"),
                                ),
                              ]),
                        ),
                        leading: CircleAvatar(
                          radius: (currentUser.id == sEller) ? 35 : 20,
                          backgroundColor: _getColorFromHex("#f0f4ff"),
                          child: Text(
                              (currentUser.id == sEller)
                                  ? "${notif[index].cus[0]}"
                                  : "A",
                              style: TextStyle(
                                  fontSize:
                                      (currentUser.id == sEller) ? 35 : 20,
                                  fontWeight: FontWeight.w700,
                                  color: _getColorFromHex("#7338ac"),
                                  fontFamily: "Poppins-Bold")),
                        ),
                        subtitle: Text(
                          timeago.format(notif[index].timestamp.toDate()),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontFamily: "Poppins-Regular"),
                        ),
                        trailing: Container(
                          height: 50.0,
                          width: 50.0,
                          child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                        notif[index].mediaUrl),
                                  ),
                                ),
                              )),
                        ),
                      ),
                    ),
                  ));
            },
          ),
          // ignore: missing_return
          onRefresh: () {
            n();
          });
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
