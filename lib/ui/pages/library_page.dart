import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:biblioteca/services/shelves_service.dart';
import 'package:biblioteca/ui/pages/add_book_page.dart';
import 'package:biblioteca/services/report_service.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final ShelvesService _shelvesService = ShelvesService();
  final TextEditingController _shelfController = TextEditingController();
  final ReportService _reportService = ReportService();

  Stream<List<Map<String, dynamic>>> _shelvesStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    return _shelvesService.getShelvesStream();
  }

  @override
  void initState() {
    super.initState();
  }

  void _addShelf(String shelfName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado.');
      }
      await _shelvesService.addShelf(shelfName);
      await _reportService.logAction('Adicionou estante: $shelfName');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
    _shelfController.clear();
    Navigator.of(context).pop();
  }

  void _navigateToAddBookPage(String shelfId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddBookPage(shelfId: shelfId),
      ),
    );
    _reportService.logAction('Navegou para adicionar livro na estante: $shelfId');
  }

  Widget _buildShelf(Map<String, dynamic> shelf) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.green.shade200, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  shelf['name'] ?? 'Estante', 
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () {
                    _navigateToAddBookPage(shelf['id']);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            (shelf['books'] != null && (shelf['books'] as List).isNotEmpty)
                ? SizedBox(
                    height: 200,
                    child: GridView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.6,
                      ),
                      itemCount: (shelf['books'] as List).length,
                      itemBuilder: (context, index) {
                        final book = shelf['books'][index];
                        return Column(
                          children: [
                            Container(
                              height: 120,
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade200,
                              ),
                              child: book['imagePath'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(book['imagePath']),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.broken_image, size: 50);
                                        },
                                      ),
                                    )
                                  : const Icon(Icons.broken_image, size: 50),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              book['title'] ?? 'Sem título',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                : const Center(
                    child: Text(
                      'Nenhum livro adicionado.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _showAddShelfDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Adicionar Estante'),
        content: TextField(
          controller: _shelfController,
          decoration: const InputDecoration(
            labelText: 'Nome da Estante',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final shelfName = _shelfController.text.trim();
              if (shelfName.isNotEmpty) {
                _addShelf(shelfName);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('O nome da estante não pode estar vazio.')),
                );
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Biblioteca'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _shelvesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }
            final shelves = snapshot.data ?? [];
            return ListView(
              children: shelves.map(_buildShelf).toList(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddShelfDialog,
        label: const Text('Nova Estante'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }
}

