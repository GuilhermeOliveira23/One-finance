import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/transacoes_screen.dart';
import 'screens/resumo_screen.dart';
import 'screens/config_screen.dart';
import 'screens/add_transacao_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Financeiro',
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _tryingSignIn = false;

  Future<void> _signInAnonymously() async {
    setState(() => _tryingSignIn = true);
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      // mostra erro amigável
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao autenticar: $e')),
      );
    } finally {
      setState(() => _tryingSignIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // aguardando conexão com o serviço auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;

        // se não autenticado, mostra botão para autenticar anonimamente
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Entrar')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Você não está autenticado'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _tryingSignIn ? null : _signInAnonymously,
                    child: _tryingSignIn
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Entrar anonimamente'),
                  ),
                ],
              ),
            ),
          );
        }

        // autenticado: pode acessar o app. Mostra UID nos logs para debug.
        debugPrint('Usuário autenticado UID: ${user.uid}');
        return const MainScreenWrapper();
      },
    );
  }
}

// wrapper simples que usa seu MainScreen (cole/ajuste baseado no seu main original)
class MainScreenWrapper extends StatelessWidget {
  const MainScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScreen(); // seu MainScreen existente
  }
}
// Cole isto no final do seu main.dart (abaixo de MainScreenWrapper)

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
        builder: (context) => const AddTransacaoScreen(),
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
      const TransacoesScreen(), // se você já fez TransacoesScreen lendo do Firestore, use const TransacoesScreen()
      const ResumoScreen(),
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