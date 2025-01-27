import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BooksService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchBooks({String shelfId = ''}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    final query = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('shelves')
        .doc(shelfId)
        .collection('books');

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> addBook({
    required String shelfId,
    required String title,
    required String author,
    required int year,
    required int numPages,
    required String genre,
    String? imagePath,
    bool isFavorite = false,
    String readingStatus = 'Not Started',
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    final bookData = {
      'title': title,
      'author': author,
      'year': year,
      'numPages': numPages,
      'genre': genre,
      'imagePath': imagePath,
      'isFavorite': isFavorite,
      'readingStatus': readingStatus,
      'addedAt': Timestamp.now(),
    };

    try {
      final shelfRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('shelves')
          .doc(shelfId);

      await _firestore.collection('users').doc(user.uid).update({
        'total_books': FieldValue.increment(1),
      });

      await shelfRef.update({
        'books': FieldValue.arrayUnion([bookData]),
      });
    } catch (e) {
      throw Exception('Erro ao adicionar livro: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllBooks() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    try {
      final shelvesSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('shelves')
          .get();

      List<Map<String, dynamic>> allBooks = [];

      for (var shelfDoc in shelvesSnapshot.docs) {

        final books = List<Map<String, dynamic>>.from(shelfDoc['books'] ?? []);

        allBooks.addAll(books);
      }

      return allBooks;
    } catch (e) {
      throw Exception('Erro ao buscar livros: $e');
    }
  }

  Future<void> removeBook({
    required String shelfId,
    required String bookId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    try {
      final shelfRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('shelves')
          .doc(shelfId);

      final shelfSnapshot = await shelfRef.get();
      final books = List<Map<String, dynamic>>.from(shelfSnapshot['books'] ?? []);

      final bookToRemove = books.firstWhere((book) => book['id'] == bookId, orElse: () => {});

      if (bookToRemove.isEmpty) {
        throw Exception('Livro não encontrado.');
      }

      await shelfRef.update({
        'books': FieldValue.arrayRemove([bookToRemove]),
      });

      await _firestore.collection('users').doc(user.uid).update({
        'total_books': FieldValue.increment(-1),
      });

    } catch (e) {
      throw Exception('Erro ao remover livro: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getBooksStream({required String shelfId}) {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('shelves')
        .doc(shelfId)
        .collection('books')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList();
        });
  }

  Future<Map<String, dynamic>> fetchBookByISBN(String isbn) async {
    final url = 'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['totalItems'] > 0) {
        final book = data['items'][0]['volumeInfo'];
        return {
          'title': book['title'],
          'author': book['authors']?.join(', ') ?? 'Unknown',
          'year': book['publishedDate']?.split('-')[0] ?? 'Unknown',
          'numPages': book['pageCount'] ?? 0,
          'genre': book['categories']?.join(', ') ?? 'Unknown',
          'imagePath': book['imageLinks']?['thumbnail'] ?? '',
        };
      } else {
        throw Exception('Livro não encontrado.');
      }
    } else {
      throw Exception('Erro ao buscar livro pelo ISBN.');
    }
  }
}
