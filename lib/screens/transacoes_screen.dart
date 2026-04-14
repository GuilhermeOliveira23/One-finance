// lib/screens/transacoes_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class TransacoesScreen extends StatelessWidget {
  // tornar estático evita conflito com construtor const
  static final FirestoreService _fs = FirestoreService();

  const TransacoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuário não autenticado')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF6A002B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transações',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _fs.transactionsStream(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erro: ${snapshot.error}'));
                    }
                    final transacoes = snapshot.data ?? [];
                    if (transacoes.isEmpty) {
                      return const Center(
                          child: Text('Nenhuma transação ainda',
                              style: TextStyle(color: Colors.white70)));
                    }
                    return ListView.builder(
                      itemCount: transacoes.length,
                      itemBuilder: (context, index) {
                        final item = transacoes[index];
                        final titulo = item['titulo'] ?? '';
                        final categoria = item['categoria'] ?? '';
                        final valor = item['valor'] ?? 0;
                        final valorFormatado = (valor is num)
                            ? 'R\$ ${valor.toStringAsFixed(2)}'
                            : valor.toString();
                        return Card(
                          color: Colors.white.withOpacity(0.12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFFF2E88),
                              child: Icon(Icons.attach_money, color: Colors.white),
                            ),
                            title: Text(titulo, style: const TextStyle(color: Colors.white)),
                            subtitle: Text(categoria, style: const TextStyle(color: Colors.white70)),
                            trailing: Text(valorFormatado, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}