import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/transacoes_screen.dart';
import 'screens/resumo_screen.dart';
import 'screens/config_screen.dart';
import 'screens/add_transacao_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // O arquivo que o comando anterior criou


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MeuApp()); // <--- Alterado de MyApp para MeuApp
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Financeiro',
      theme: ThemeData(useMaterial3: true),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int paginaAtual = 2;

  final List<Map<String, String>> transacoes = [
    {'titulo': 'Cinema', 'categoria': 'Variáveis', 'valor': '- R\$ 50,00'},
    {'titulo': 'Mercado', 'categoria': 'Variáveis', 'valor': '- R\$ 180,00'},
  ];

  Future<void> abrirTelaAdicionar() async {
    final novaTransacao = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransacaoScreen(),
      ),
    );

    if (novaTransacao != null && novaTransacao is Map<String, String>) {
      setState(() {
        transacoes.insert(0, novaTransacao);
        paginaAtual = 2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final paginas = [
     const HomePage(),
      TransacoesScreen(transacoes: transacoes),
      ResumoScreen(transacoes: transacoes),
      const ConfigScreen(),
    ];

    return Scaffold(
      body: paginas[paginaAtual],
      floatingActionButton: FloatingActionButton(
        onPressed: abrirTelaAdicionar,
        backgroundColor: const Color(0xFFFF2E88),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF5A0026),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              itemMenu(Icons.home, 'Home', 0),
              itemMenu(Icons.swap_horiz, 'Transações', 1),
              const SizedBox(width: 30),
              itemMenu(Icons.receipt_long, 'Resumo', 2),
              itemMenu(Icons.settings, 'Config.', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget itemMenu(IconData icon, String texto, int index) {
    final ativo = paginaAtual == index;
    return InkWell(
      onTap: () {
        setState(() {
          paginaAtual = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: ativo ? Colors.white : Colors.white70),
          const SizedBox(height: 4),
          Text(
            texto,
            style: TextStyle(
              color: ativo ? Colors.white : Colors.white70,
              fontSize: 12,
              fontWeight: ativo ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}