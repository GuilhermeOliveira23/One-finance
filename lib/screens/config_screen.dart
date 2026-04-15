import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/usuario.dart';
import '../services/firestore_service.dart';
import 'editar_perfil_screen.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  bool notifications = true;
  bool darkMode = false;

  final FirestoreService _fs = FirestoreService();
  Usuario? _usuario;
  bool _loading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        setState(() => _loading = false);
        return;
      }
      final usuario = await _fs.getUserProfile(uid);
      setState(() {
        _usuario = usuario;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _erro = 'Não foi possível carregar o perfil. Tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7A0030), Color(0xFF8A0035), Color(0xFF650028)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _erro != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.white70, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            _erro!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _carregarPerfil,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tentar novamente'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white24,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Configurações',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),

                      // Perfil
                      Card(
                        color: Colors.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundImage: _usuario?.avatarUrl.isNotEmpty == true
                                ? AssetImage(_usuario!.avatarUrl)
                                : const AssetImage('assets/avatar.png'),
                          ),
                          title: Text(
                            _usuario?.nome.isNotEmpty == true
                                ? _usuario!.nome
                                : 'Sem nome',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            _usuario?.email.isNotEmpty == true
                                ? _usuario!.email
                                : 'Sem e-mail',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing:
                              const Icon(Icons.edit, color: Colors.white),
                          onTap: _usuario == null
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditarPerfilScreen(
                                        usuario: _usuario!,
                                        onSalvar: (usuarioAtualizado) {
                                          setState(() {
                                            _usuario = usuarioAtualizado;
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Notificações
                      Card(
                        color: Colors.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        child: ListTile(
                          leading: const Icon(Icons.notifications,
                              color: Colors.white),
                          title: const Text('Notificações',
                              style: TextStyle(color: Colors.white)),
                          trailing: Switch(
                            value: notifications,
                            onChanged: (value) =>
                                setState(() => notifications = value),
                            activeColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tema Escuro
                      Card(
                        color: Colors.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        child: ListTile(
                          leading: const Icon(Icons.dark_mode,
                              color: Colors.white),
                          title: const Text('Tema Escuro',
                              style: TextStyle(color: Colors.white)),
                          trailing: Switch(
                            value: darkMode,
                            onChanged: (value) =>
                                setState(() => darkMode = value),
                            activeColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}