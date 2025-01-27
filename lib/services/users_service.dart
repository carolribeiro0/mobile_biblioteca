import 'dart:io'; // Para trabalhar com arquivos
import 'package:image_picker/image_picker.dart'; // Para selecionar a imagem
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Retorna um Stream para acompanhar as atualizações em tempo real
  Stream<DocumentSnapshot> getUserDataStream() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('users').doc(user.uid).snapshots();
    } else {
      throw Exception('Usuário não autenticado');
    }
  }

  // Função para pegar a imagem
  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path); // Retorna o arquivo de imagem
    }
    return null;
  }

  // Função para salvar a imagem localmente
  Future<String?> saveImageLocally(File imageFile) async {
    try {
      // Obtendo o diretório local do dispositivo
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg'; // Nome único para a imagem
      final localImagePath = '${directory.path}/$fileName'; // Caminho completo para salvar a imagem

      // Salvando a imagem no diretório local
      await imageFile.copy(localImagePath); 

      return localImagePath; // Retorna o caminho local onde a imagem foi salva
    } catch (e) {
      print("Erro ao salvar a imagem localmente: $e");
      return null;
    }
  }

  // Função para atualizar a imagem de perfil no Firestore
  Future<void> updateProfilePictureInFirestore(String localImagePath) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'profile_picture': localImagePath, // Salva o caminho local no Firestore
        });
      } catch (e) {
        print("Erro ao atualizar a imagem no Firestore: $e");
      }
    } else {
      print('Usuário não autenticado');
    }
  }

  // Função para mudar a foto de perfil
  Future<void> changeProfilePicture() async {
    File? imageFile = await pickImage();
    if (imageFile != null) {
      // Salva a imagem localmente e pega o caminho
      String? localImagePath = await saveImageLocally(imageFile);
      if (localImagePath != null) {
        // Atualiza o Firestore com o caminho da imagem
        await updateProfilePictureInFirestore(localImagePath);
      }
    }
  }
}
