import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShelvesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para adicionar uma nova estante
  Future<void> addShelf(String shelfName) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("Usuário não autenticado.");
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('shelves')
        .add({'name': shelfName, 'books': []});
  }

  // Método para obter a lista de estantes
  Future<List<Map<String, dynamic>>> getShelves() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("Usuário não autenticado.");
    }

    final shelvesSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('shelves')
        .get();

    return shelvesSnapshot.docs.map((doc) {
      return {'id': doc.id, ...doc.data()};
    }).toList();
  }

  // Método para obter a lista de estantes em tempo real (stream)
  Stream<List<Map<String, dynamic>>> getShelvesStream() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("Usuário não autenticado.");
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('shelves')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList();
        });
  }

  // Método para contar o número de estantes criadas
  Future<int> countShelves() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("Usuário não autenticado.");
    }

    final shelvesSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('shelves')
        .get();

    return shelvesSnapshot.size;  // Retorna o número de estantes
  }
}
