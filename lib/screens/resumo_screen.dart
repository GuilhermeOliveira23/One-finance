import 'package:flutter/material.dart';

class ResumoScreen extends StatelessWidget {
  final List<Map<String, String>> transacoes;

  const ResumoScreen({super.key, required this.transacoes});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE9C6D1),
      child: SafeArea(
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
            child: SingleChildScrollView(
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
                    'R\$ 2.350,00',
                    '45,0%',
                    Icons.add,
                    const Color(0xFF6B63FF),
                  ),
                  const SizedBox(height: 12),
                  _categoriaCard(
                    'FIXAS',
                    'Fixas',
                    'R\$ 5.600,00',
                    '45,0%',
                    Icons.show_chart,
                    const Color(0xFF49D17E),
                  ),
                  const SizedBox(height: 12),
                  _categoriaCard(
                    'INVESTIMENTOS',
                    'Investimentos',
                    'R\$ 2.900,00',
                    '10,0%',
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
                        item['titulo'] ?? '',
                        item['categoria'] ?? '',
                        item['valor'] ?? '',
                      ),
                    ),
                  ),
                ],
              ),
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
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(categoria, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Text(
            valor,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}