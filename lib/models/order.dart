import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String orderId;
  final String postId;
  final String item;
  final String mediaUrl;
  final String userId;
  final String cus;
  final String cost;
  final String status;
  final int quantity;
      final List<dynamic> cnotif;
  final List<dynamic> anotif;
  final Timestamp timestamp;

  Order(
      {this.orderId,
      this.postId,
      this.item,
      this.mediaUrl,
      this.userId,
      this.cost,
      this.cus,
      this.status,
      this.quantity,
        this.cnotif,
      this.anotif,
   
      this.timestamp});

  factory Order.fromDocument(DocumentSnapshot doc) {
    return Order(
        orderId: doc['orderId'],
        postId: doc['postId'],
        item: doc['item'],
        mediaUrl: doc['mediaUrl'],
        userId: doc['userId'],
        cost: doc['cost'],
        cus: doc['cus'],
           cnotif: doc['cnotif'],
        anotif: doc['anotif'],
        status: doc['status'],
        quantity: doc['quantity'],
        timestamp: doc['timestamp']);
  }
}
