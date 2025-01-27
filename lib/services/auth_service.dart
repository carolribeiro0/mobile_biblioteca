import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      // Cria o usuário no Firebase Authentication
      UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Extrai o nome antes do "@"
      String name = email.split('@')[0];

      // Salva os dados do usuário no Firestore, usando o UID como ID do documento
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'profile_picture': '', // Pode ser uma URL padrão ou vazia
        'total_books': 0,
        'created_shelves': 0,
        'books_read': 0,
      });

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }

  String? getCurrentUserEmail() {
    return _firebaseAuth.currentUser?.email;
  }

  Future<void> signInAnonymously() async {
    try {
      await _firebaseAuth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }
}
