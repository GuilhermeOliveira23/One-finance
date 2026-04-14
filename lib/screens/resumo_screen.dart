import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'package:intl/intl.dart';

class ResumoScreen extends StatelessWidget {
  const ResumoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuário não autenticado')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE9C6D1),
      body: SafeArea(
        child: Center(
          child: Container(
            width: 390,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(38),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF7A0030),
                  Color(0xFF90003D),
                  Color(0xFF6A002B),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirestoreService().transactionsStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                final transacoes = snapshot.data ?? [];

                // calcula totais por categoria
                double totalVariaveis = 0;
                double totalFixas = 0;
                double totalInvestimentos = 0;
                double totalGeral = 0;

                for (final item in transacoes) {
                  // garante que valor é numérico
                  final valorRaw = item['valor'];
                  double valor = 0;
                  if (valorRaw is num) {
                    valor = valorRaw.toDouble();
                  } else if (valorRaw is String) {
                    valor = double.tryParse(valorRaw.replaceAll(',', '.')) ?? 0;
                  }
                  final categoria = (item['categoria'] ?? '').toString().toLowerCase();
                  if (categoria.contains('vari')) {
                    totalVariaveis += valor;
                  } else if (categoria.contains('fix')) {
                    totalFixas += valor;
                  } else if (categoria.contains('invest')) {
                    totalInvestimentos += valor;
                  } else {
                    // se quiser tratar outras categorias, adicione aqui
                  }
                  totalGeral += valor;
                }

                final fmt = NumberFormat.simpleCurrency(locale: 'pt_BR');

                String formatValue(double v) => fmt.format(v);

                double pct(double part) =>
                    totalGeral > 0 ? (part / totalGeral * 100) : 0;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Categorias',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _categoriaCard(
                        'VARIÁVEIS',
                        'Variáveis',
                        formatValue(totalVariaveis),
                        '${pct(totalVariaveis).toStringAsFixed(1)}%',
                        Icons.add,
                        const Color(0xFF6B63FF),
                      ),
                      const SizedBox(height: 12),
                      _categoriaCard(
                        'FIXAS',
                        'Fixas',
                        formatValue(totalFixas),
                        '${pct(totalFixas).toStringAsFixed(1)}%',
                        Icons.show_chart,
                        const Color(0xFF49D17E),
                      ),
                      const SizedBox(height: 12),
                      _categoriaCard(
                        'INVESTIMENTOS',
                        'Investimentos',
                        formatValue(totalInvestimentos),
                        '${pct(totalInvestimentos).toStringAsFixed(1)}%',
                        Icons.bar_chart,
                        const Color(0xFFFF7D59),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Transações Recentes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...transacoes.take(5).map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _transacaoCard(
                            item['titulo']?.toString() ?? '',
                            item['categoria']?.toString() ?? '',
                            // mostra valor formatado
                            item['valor'] is num
                                ? formatValue((item['valor'] as num).toDouble())
                                : (item['valor']?.toString() ?? ''),
                          ),
                        ),
                      ),
                      if (transacoes.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            'Nenhuma transação ainda',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoriaCard(String titulo, String subtitulo, String valor,
      String porcentagem, IconData icone, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: cor,
            child: Icon(icone, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(subtitulo, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                valor,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                porcentagem,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _transacaoCard(String titulo, String categoria, String valor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFFF2E88),
            child: Icon(Icons.attach_money, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(categoria, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Text(valor, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}