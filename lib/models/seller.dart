import 'package:cloud_firestore/cloud_firestore.dart';

class Seller {
  final String id;

  Seller({
    this.id,
  });

  factory Seller.fromDocument(DocumentSnapshot doc) {
    return Seller(
      id: doc['seller'],
    );
  }
}
