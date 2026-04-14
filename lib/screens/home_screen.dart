import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryAppColor = Color(0xFFD31046);
    const Color accentPink = Color(0xFFFF007F);
    const Color darkCardColor = Color(0xFFE91050);

    final currencyFormatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuário não autenticado')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Resumo Financeiro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryAppColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().transactionsStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final transacoes = snapshot.data ?? [];

          double totalReceitas = 0;
          double totalDespesas = 0;
          for (final item in transacoes) {
            final valorRaw = item['valor'];
            double valor = 0;
            if (valorRaw is num) {
              valor = valorRaw.toDouble();
            } else if (valorRaw is String) {
              valor = double.tryParse(valorRaw.replaceAll(',', '.')) ?? 0;
            }
            final tipo = (item['tipo'] ?? 'Despesa').toString();
            if (tipo == 'Receita') {
              totalReceitas += valor;
            } else {
              totalDespesas += valor;
            }
          }
          final saldo = totalReceitas - totalDespesas;

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(16.0),
                elevation: 8,
                shadowColor: primaryAppColor.withOpacity(0.4),
                color: darkCardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saldo Total',
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currencyFormatter.format(saldo),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Divider(
                          height: 40, thickness: 1, color: Colors.white30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildOverviewItem(
                              icon: Icons.arrow_downward,
                              label: 'Receitas',
                              amount: totalReceitas,
                              color: const Color(0xFF00E676),
                              formatter: currencyFormatter,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildOverviewItem(
                              icon: Icons.arrow_upward,
                              label: 'Despesas',
                              amount: totalDespesas,
                              color: const Color(0xFFFF8A65),
                              formatter: currencyFormatter,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transações Recentes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: transacoes.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhuma transação ainda!\nComece adicionando uma.',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: transacoes.length,
                        itemBuilder: (ctx, index) {
                          final item = transacoes[index];
                          final titulo = item['titulo']?.toString() ?? '';
                          final categoria =
                              item['categoria']?.toString() ?? '';
                          final valorRaw = item['valor'];
                          double valor = 0;
                          if (valorRaw is num) {
                            valor = valorRaw.toDouble();
                          } else if (valorRaw is String) {
                            valor = double.tryParse(
                                    valorRaw.replaceAll(',', '.')) ??
                                0;
                          }
                          final tipo =
                              (item['tipo'] ?? 'Despesa').toString();
                          final isReceita = tipo == 'Receita';
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            color: Colors.grey[50],
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              leading: Container(
                                decoration: BoxDecoration(
                                  color: accentPink,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: const Icon(
                                  Icons.attach_money,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                titulo,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                categoria,
                                style:
                                    TextStyle(color: Colors.grey[600]),
                              ),
                              trailing: Text(
                                '${isReceita ? '' : '- '}${currencyFormatter.format(valor)}',
                                style: TextStyle(
                                  color: isReceita
                                      ? const Color(0xFF2E7D32)
                                      : primaryAppColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewItem({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
    required NumberFormat formatter,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          formatter.format(amount),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}