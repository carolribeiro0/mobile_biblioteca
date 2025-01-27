import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biblioteca/services/users_service.dart';
import 'package:biblioteca/services/auth_service.dart';
import 'package:biblioteca/services/books_service.dart';
import 'package:biblioteca/services/shelves_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserService userService = UserService();
    final AuthService authService = AuthService();
    final BooksService booksService = BooksService();
    final ShelvesService shelvesService = ShelvesService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userService.getUserDataStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Dados do usuário não encontrados.'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String nome = userData['name'] ?? 'Username';
          String email = userData['email'] ?? 'Email não disponível';
          String fotoUrl = userData['profile_picture'] ?? 'assets/default_avatar.png';

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: booksService.fetchAllBooks(),
            builder: (context, booksSnapshot) {
              if (booksSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (booksSnapshot.hasError) {
                return Center(child: Text('Erro ao buscar livros: ${booksSnapshot.error}'));
              }

              int livrosNoTotal = booksSnapshot.data?.length ?? 0;
              int livrosLidos = userData['books_read'] ?? 0;

              return FutureBuilder<int>(
                future: shelvesService.countShelves(),
                builder: (context, shelvesSnapshot) {
                  if (shelvesSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (shelvesSnapshot.hasError) {
                    return Center(child: Text('Erro ao contar estantes: ${shelvesSnapshot.error}'));
                  }

                  int estantesCriadas = shelvesSnapshot.data ?? 0;

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: fotoUrl.startsWith('http')
                                  ? NetworkImage(fotoUrl)
                                  : fotoUrl.startsWith('assets') 
                                      ? AssetImage(fotoUrl) as ImageProvider
                                      : FileImage(File(fotoUrl)),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () async {
                                  await userService.changeProfilePicture();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Foto de perfil atualizada!')),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.blueAccent,
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          nome,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatisticCard(label: 'Livros Lidos', count: livrosLidos),
                            _StatisticCard(label: 'Estantes Criadas', count: estantesCriadas),
                            _StatisticCard(label: 'Livros no Total', count: livrosNoTotal),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Spacer(),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          onPressed: () async {
                            await authService.signOut();
                            Navigator.of(context).pushReplacementNamed('/login');
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final String label;
  final int count;

  const _StatisticCard({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}