// lib/main.dart
import 'package:flutter/foundation.dart' show kIsWeb;
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

  // Forçar persistência no Web para manter sessão após reload
  if (kIsWeb) {
    try {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
      debugPrint('FirebaseAuth: set persistence = LOCAL (web)');
    } catch (e) {
      debugPrint('Erro ao setar persistence (pode ser que não seja web): $e');
    }
  }

  // Se não houver user, tenta login anônimo (não cria novo se já existir)
  try {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
      debugPrint('Chamou signInAnonymously()');
    }
  } catch (e) {
    debugPrint('Erro ao autenticar anonimamente no startup: $e');
  }

  // Log do user atual (se existir)
  final currentUser = FirebaseAuth.instance.currentUser;
  debugPrint('Startup UID: ${currentUser?.uid}');

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
      final user = FirebaseAuth.instance.currentUser;
      debugPrint('Entrou anonimamente. UID = ${user?.uid}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao autenticar: $e')),
      );
      debugPrint('Erro ao autenticar anonimamente: $e');
    } finally {
      setState(() => _tryingSignIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // aguardando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;

        // não autenticado -> botão para entrar anonimamente
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

        // autenticado: mostra app (log do UID para debug)
        debugPrint('Auth state: usuário autenticado UID = ${user.uid}');
        return const MainScreenWrapper();
      },
    );
  }
}

// wrapper para usar seu MainScreen existente
class MainScreenWrapper extends StatelessWidget {
  const MainScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Se sua MainScreen estiver num outro arquivo, importe e use aqui.
    return MainScreen();
  }
}


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int paginaAtual = 1; // 0=Home,1=Transações,2=Resumo,3=Config

  Future<void> abrirTelaAdicionar() async {
    // abre a tela de adicionar (ela salva direto no Firestore)
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTransacaoScreen()),
    );
    // volta para a aba de Transações para ver as mudanças
    setState(() => paginaAtual = 1);
  }

  @override
  Widget build(BuildContext context) {
    final paginas = [
      const HomePage(),
      const TransacoesScreen(), // usa Stream do Firestore
      const ResumoScreen(),      // usa Stream do Firestore
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
              _itemMenu(Icons.home, 'Home', 0),
              _itemMenu(Icons.swap_horiz, 'Transações', 1),
              const SizedBox(width: 30),
              _itemMenu(Icons.receipt_long, 'Resumo', 2),
              _itemMenu(Icons.settings, 'Config.', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemMenu(IconData icon, String texto, int index) {
    final ativo = paginaAtual == index;
    return InkWell(
      onTap: () => setState(() => paginaAtual = index),
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