import 'package:flutter/material.dart';
import 'add_transacao_screen.dart';
class TransacoesScreen extends StatelessWidget {
  final List<Map<String, String>> transacoes;

  const TransacoesScreen({super.key, required this.transacoes});

  @override
  Widget build(BuildContext context) {
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
                child: ListView.builder(
                  itemCount: transacoes.length,
                  itemBuilder: (context, index) {
                    final item = transacoes[index];
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
                        title: Text(
                          item['titulo'] ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          item['categoria'] ?? '',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Text(
                          item['valor'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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