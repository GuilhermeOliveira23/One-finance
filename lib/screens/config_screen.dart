import 'package:flutter/material.dart';
import '../models/usuario.dart';
import 'editar_perfil_screen.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  bool notifications = true;
  bool darkMode = false;

  Usuario usuario = Usuario(
    nome: "Erick Silva",
    email: "erick@email.com",
    avatarUrl: "assets/avatar.png",
  );

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
          child: SingleChildScrollView(
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage(usuario.avatarUrl),
                    ),
                    title: Text(usuario.nome,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(usuario.email,
                        style: const TextStyle(color: Colors.white70)),
                    trailing: const Icon(Icons.edit, color: Colors.white),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditarPerfilScreen(
                            usuario: usuario,
                            onSalvar: (usuarioAtualizado) {
                              setState(() {
                                usuario = usuarioAtualizado;
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: ListTile(
                    leading: const Icon(Icons.notifications, color: Colors.white),
                    title: const Text('Notificações', style: TextStyle(color: Colors.white)),
                    trailing: Switch(
                      value: notifications,
                      onChanged: (value) => setState(() => notifications = value),
                      activeColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Tema Escuro
                Card(
                  color: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: ListTile(
                    leading: const Icon(Icons.dark_mode, color: Colors.white),
                    title: const Text('Tema Escuro', style: TextStyle(color: Colors.white)),
                    trailing: Switch(
                      value: darkMode,
                      onChanged: (value) => setState(() => darkMode = value),
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