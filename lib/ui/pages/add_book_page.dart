import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:biblioteca/services/books_service.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:biblioteca/services/report_service.dart';

class AddBookPage extends StatefulWidget {
  final String shelfId;

  const AddBookPage({Key? key, required this.shelfId}) : super(key: key);

  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final BooksService _booksService = BooksService();
  final TextEditingController _bookNameController = TextEditingController();
  final ReportService _reportService = ReportService();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _numPagesController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  String? _selectedGenre;

  final List<String> _genres = [
    'Aventura',
    'Biografia',
    'Clássico',
    'Comédia',
    'Conto',
    'Drama',
    'Fantasia',
    'Ficção Científica',
    'História',
    'Infantil',
    'Mistério',
    'Poesia',
    'Policial',
    'Romance',
    'Suspense',
    'Terror',
    'Autoajuda',
    'Distopia',
    'Literatura Juvenil',
    'Épico',
    'História em Quadrinhos',
    'Thriller',
    'Fantasia Urbana',
    'Ficção Histórica',
    'Viagem no Tempo',
    'Espionagem',
    'Religião/Espiritualidade',
    'Ensaios',
    'Crônicas',
    'Filosofia',
    'Tecnologia',
    'Ciência',
    'Saúde',
    'Humor',
    'Erótico',
    'Gastronomia',
    'Arte e Fotografia',
  ];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _scanISBN() async {
    try {
      final result = await BarcodeScanner.scan();
      final isbn = result.rawContent;

      if (isbn.isNotEmpty) {
        final bookData = await _booksService.fetchBookByISBN(isbn);
        setState(() {
          _bookNameController.text = bookData['title'];
          _authorController.text = bookData['author'];
          _yearController.text = bookData['year'];
          _numPagesController.text = bookData['numPages'].toString();
          _selectedGenre = _genres.contains(bookData['genre']) ? bookData['genre'] : null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao ler ISBN: $e')),
      );
    }
  }

  Future<void> _addBook() async {
    try {
      if (!_formKey.currentState!.validate()) return;

      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione uma imagem.')),
        );
        return;
      }

      await _booksService.addBook(
        shelfId: widget.shelfId,
        title: _bookNameController.text,
        author: _authorController.text,
        year: int.parse(_yearController.text),
        numPages: int.parse(_numPagesController.text),
        genre: _selectedGenre ?? '',
        imagePath: _selectedImage!.path,
      );

      await _reportService.logAction('Adicionou um livro: ${_bookNameController.text}');
      
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livro adicionado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar livro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Livro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _bookNameController,
                  decoration: const InputDecoration(labelText: 'Título do Livro'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o título do livro';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _authorController,
                  decoration: const InputDecoration(labelText: 'Autor'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o autor';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _yearController,
                  decoration: const InputDecoration(labelText: 'Ano'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o ano';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Insira um ano válido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _numPagesController,
                  decoration: const InputDecoration(labelText: 'Número de Páginas'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o número de páginas';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Insira um número válido';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedGenre,
                  decoration: const InputDecoration(labelText: 'Gênero'),
                  items: _genres
                      .map((genre) => DropdownMenuItem(
                            value: genre,
                            child: Text(genre),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGenre = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, selecione um gênero';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover)
                        : const Center(
                            child: Text(
                              'Clique para selecionar uma imagem',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addBook,
                  child: const Text('Adicionar Livro'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _scanISBN,
                  child: const Text('Ler ISBN do Livro'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
