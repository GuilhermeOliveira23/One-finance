import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/usuario.dart';
import '../services/firestore_service.dart';

class EditarPerfilScreen extends StatefulWidget {
  final Usuario usuario;
  final Function(Usuario) onSalvar;

  const EditarPerfilScreen(
      {super.key, required this.usuario, required this.onSalvar});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  late TextEditingController nomeController;
  late TextEditingController emailController;
  late String avatarUrl;
  bool _saving = false;

  final FirestoreService _fs = FirestoreService();

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.usuario.nome);
    emailController = TextEditingController(text: widget.usuario.email);
    avatarUrl = widget.usuario.avatarUrl;
  }

  Future<void> salvar() async {
    if (nomeController.text.isEmpty || emailController.text.isEmpty) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final usuarioAtualizado = Usuario(
        nome: nomeController.text,
        email: emailController.text,
        avatarUrl: avatarUrl,
      );

      await _fs.saveUserProfile(uid, usuarioAtualizado);
      widget.onSalvar(usuarioAtualizado);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  void trocarFoto() {
    setState(() {
      avatarUrl = avatarUrl == "assets/avatar.png"
          ? "assets/avatar2.png"
          : "assets/avatar.png";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7A0030),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A0030),
        foregroundColor: Colors.white,
        title: const Text("Editar Perfil"),
        actions: [
          _saving
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  ),
                )
              : IconButton(icon: const Icon(Icons.save), onPressed: salvar),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: trocarFoto,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage(avatarUrl),
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.edit, size: 18, color: Colors.black),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: nomeController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Nome",
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saving ? null : salvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF2E88),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Salvar Alterações",
                      style:
                          TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}