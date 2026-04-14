// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Transactions ──────────────────────────────────────────────────────────

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

  // ── User profile ──────────────────────────────────────────────────────────

  /// Returns the stored profile, or a default if it doesn't exist yet.
  Future<Usuario> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return Usuario.fromMap(doc.data()!);
    }
    return Usuario(nome: '', email: '', avatarUrl: 'assets/avatar.png');
  }

  /// Persists (creates or updates) the user profile document.
  Future<void> saveUserProfile(String uid, Usuario usuario) {
    return _db
        .collection('users')
        .doc(uid)
        .set(usuario.toMap(), SetOptions(merge: true));
  }
}