import 'package:flutter/material.dart';
import 'package:biblioteca/services/books_service.dart';
import 'dart:io';

class BooksPage extends StatefulWidget {
  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  final BooksService _booksService = BooksService();
  List<Map<String, dynamic>> _allBooks = [];
  List<Map<String, dynamic>> _displayedBooks = [];
  bool _isLoading = false;
  String? _selectedGenre;
  String? _sortOrder;
  String _searchQuery = '';

  final List<String> _genres = [
    'Todos',
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

  final List<String> _sortOptions = [
    'Título (A-Z)',
    'Título (Z-A)',
    'Autor (A-Z)',
    'Autor (Z-A)',
  ];

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final books = await _booksService.fetchAllBooks();

      setState(() {
        _allBooks = books;
        _displayedBooks = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterBooks() {
    setState(() {
      _displayedBooks = _allBooks.where((book) {
        if (_selectedGenre != null && _selectedGenre != 'Todos' && book['genre'] != _selectedGenre) {
          return false;
        }
        if (_searchQuery.isNotEmpty) {
          final title = book['title']?.toLowerCase() ?? '';
          final author = book['author']?.toLowerCase() ?? '';
          if (!title.contains(_searchQuery.toLowerCase()) && !author.contains(_searchQuery.toLowerCase())) {
            return false;
          }
        }
        return true;
      }).toList();

      if (_sortOrder != null) {
        _displayedBooks.sort((a, b) {
          if (_sortOrder == 'Título (A-Z)') {
            return a['title'].toLowerCase().compareTo(b['title'].toLowerCase());
          } else if (_sortOrder == 'Título (Z-A)') {
            return b['title'].toLowerCase().compareTo(a['title'].toLowerCase());
          } else if (_sortOrder == 'Autor (A-Z)') {
            return a['author'].toLowerCase().compareTo(b['author'].toLowerCase());
          } else if (_sortOrder == 'Autor (Z-A)') {
            return b['author'].toLowerCase().compareTo(a['author'].toLowerCase());
          }
          return 0;
        });
      }
    });
  }

  void _searchBooks(String query) {
    setState(() {
      _searchQuery = query;
      _filterBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Livros'),
        actions: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                ),
                onChanged: (query) => _searchBooks(query),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                        ),
                        DropdownButtonFormField<String>(
                          value: _sortOrder,
                          decoration: const InputDecoration(labelText: 'Ordenar por'),
                          items: _sortOptions
                              .map((option) => DropdownMenuItem(
                                    value: option,
                                    child: Text(option),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _sortOrder = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            _filterBooks();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Aplicar Filtros'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _displayedBooks.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum livro encontrado.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(10.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: _displayedBooks.length,
                  itemBuilder: (context, index) {
                    final book = _displayedBooks[index];
                    return GestureDetector(
                      onTap: () {
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                              child: book['imagePath'] != null
                                  ? Image.file(
                                      File(book['imagePath']),
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.broken_image, size: 180);
                                      },
                                    )
                                  : Container(
                                      height: 180,
                                      width: double.infinity,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image, size: 80),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    book['title'] ?? 'Sem título',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    book['author'] ?? 'Autor desconhecido',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class BookSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearch;

  BookSearchDelegate({required this.onSearch});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearch(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onSearch(query);
    });

    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Text(
        'Digite um termo para buscar.',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}