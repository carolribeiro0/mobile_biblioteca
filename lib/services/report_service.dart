import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> logAction(String action) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    final logData = {
      'action': action,
      'timestamp': Timestamp.now(),
    };

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('reports')
          .add(logData);
    } catch (e) {
      throw Exception('Erro ao registrar ação: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getReportsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('reports')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList();
        });
  }
}
