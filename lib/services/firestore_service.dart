// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addTransaction(String uid, {
    required String titulo,
    required String categoria,
    required double valor,
  }) {
    final col = _db.collection('users').doc(uid).collection('transactions');
    return col.add({
      'titulo': titulo,
      'categoria': categoria,
      'valor': valor,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> transactionsStream(String uid) {
    final col = _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('createdAt', descending: true);

    return col.snapshots().map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}