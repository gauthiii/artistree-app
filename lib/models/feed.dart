import 'package:cloud_firestore/cloud_firestore.dart';

class Feed {
  final String orderId;
  final String feedId;
  final String notifId;
  final String status;
  final String mediaUrl;
 
  final String cus;

  final Timestamp timestamp;

  Feed(
      {this.orderId,
      this.status,
      this.feedId,
      this.notifId,
      this.mediaUrl,
      this.cus,
    
      this.timestamp});

  factory Feed.fromDocument(DocumentSnapshot doc) {
    return Feed(
        orderId: doc['orderId'],
        notifId: doc['notifId'],
        feedId: doc['postId'],
        mediaUrl: doc['mediaUrl'],
        cus: doc['cus'],
     
        timestamp: doc['timestamp'],
        status: doc['status']);
  }
}
