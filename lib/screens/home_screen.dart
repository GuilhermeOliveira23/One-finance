import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importe necessário para formatação de moeda e data

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Transaction> _transactions = [
    Transaction(
      id: 't1',
      title: 'Salário',
      amount: 5600.00,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: TransactionType.income,
    ),
    Transaction(
      id: 't2',
      title: 'Mercado',
      amount: 180.00,
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: TransactionType.expense,
    ),
    Transaction(
      id: 't3',
      title: 'Cinema',
      amount: 50.00,
      date: DateTime.now().subtract(const Duration(days: 3)),
      type: TransactionType.expense, // Assumindo despesa baseado no nome
    ),
    Transaction(
      id: 't4',
      title: 'Projeto Freelance',
      amount: 500.00,
      date: DateTime.now().subtract(const Duration(days: 5)),
      type: TransactionType.income,
    ),
    Transaction(
      id: 't5',
      title: 'Café',
      amount: 15.50,
      date: DateTime.now().subtract(const Duration(hours: 3)),
      type: TransactionType.expense,
    ),
    Transaction(
      id: 't6',
      title: 'Aluguel',
      amount: 1200.00,
      date: DateTime.now().subtract(const Duration(days: 10)),
      type: TransactionType.expense,
    ),
    Transaction(
      id: 't7',
      title: 'Investimento Renda Fixa',
      amount: 2900.00,
      date: DateTime.now().subtract(const Duration(days: 8)),
      type: TransactionType.income,
    ),
  ];

  double get _totalBalance {
    double totalIncome = _transactions
        .where((tx) => tx.type == TransactionType.income)
        .fold(0.0, (sum, item) => sum + item.amount);
    double totalExpense = _transactions
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
    return totalIncome - totalExpense;
  }

  double get _totalIncome {
    return _transactions
        .where((tx) => tx.type == TransactionType.income)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get _totalExpenses {
    return _transactions
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryAppColor = Color(0xFFD31046); // Vermelho/Rosa escuro
    const Color accentPink = Color(0xFFFF007F); // Rosa choque (FAB)
    const Color darkCardColor = Color(0xFFE91050); // Fundo do card principal

    final currencyFormatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);

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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Botão de configurações pressionado!')));
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
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
                children: <Widget>[
                  const Text(
                    'Saldo Total',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormatter.format(_totalBalance),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Divider(height: 40, thickness: 1, color: Colors.white30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[

                      Expanded(
                        child: _buildOverviewItem(
                          icon: Icons.arrow_downward,
                          label: 'Receitas',
                          amount: _totalIncome,
                          color: const Color(0xFF00E676), // Verde vibrante da imagem
                          formatter: currencyFormatter,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildOverviewItem(
                          icon: Icons.arrow_upward,
                          label: 'Despesas',
                          amount: _totalExpenses,
                          color: const Color(0xFFFF8A65), // Laranja/Avermelhado para contraste
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transações Recentes', // Texto idêntico à imagem
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Botão Ver Tudo pressionado!')));
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: primaryAppColor,
                  ),
                  child: const Text('Ver Tudo'),
                ),
              ],
            ),
          ),

          Expanded(
            child: _transactions.isEmpty
                ? Center(
                    child: Text(
                      'Nenhuma transação ainda!\nComece adicionando uma.',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (ctx, index) {
                      final tx = _transactions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        color: Colors.grey[50], // Fundo sutil do card
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          leading: Container(
                            decoration: BoxDecoration(
                              color: accentPink, // Fundo do ícone
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
                            tx.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            DateFormat('dd/MM/yyyy - HH:mm').format(tx.date), // Formato brasileiro
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: Text(
                            '${tx.type == TransactionType.income ? '' : '- '}${currencyFormatter.format(tx.amount)}',
                            style: TextStyle(
                              color: tx.type == TransactionType.income
                                  ? const Color(0xFF2E7D32) // Verde escuro para receita na lista
                                  : primaryAppColor, // Vermelho da paleta para despesa
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Você clicou em ${tx.title}')));
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Botão Adicionar Transação pressionado!')));
        },
        backgroundColor: accentPink,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Centralizado na parte inferior para remeter ao layout
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