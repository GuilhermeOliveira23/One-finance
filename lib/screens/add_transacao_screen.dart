import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class AddTransacaoScreen extends StatefulWidget {
  const AddTransacaoScreen({super.key});

  @override
  State<AddTransacaoScreen> createState() => _AddTransacaoScreenState();
}

class _AddTransacaoScreenState extends State<AddTransacaoScreen> {
  final tituloController = TextEditingController();
  final valorController = TextEditingController();
  String categoriaSelecionada = 'Variáveis';
  final FirestoreService _fs = FirestoreService();
  bool _loading = false;

  void salvar() async {
    if (tituloController.text.isEmpty || valorController.text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado')),
      );
      return;
    }

    final valor = double.tryParse(valorController.text.replaceAll(',', '.'));
    if (valor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valor inválido')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _fs.addTransaction(user.uid,
          titulo: tituloController.text,
          categoria: categoriaSelecionada,
          valor: valor);
      // fecha a tela depois de salvar
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7A0030),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A0030),
        foregroundColor: Colors.white,
        title: const Text('Adicionar Transação'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: tituloController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Título',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valorController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Valor',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: categoriaSelecionada,
              dropdownColor: const Color(0xFF8A0035),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Categoria',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              items: const [
                DropdownMenuItem(value: 'Variáveis', child: Text('Variáveis')),
                DropdownMenuItem(value: 'Fixas', child: Text('Fixas')),
                DropdownMenuItem(
                    value: 'Investimentos', child: Text('Investimentos')),
              ],
              onChanged: (value) {
                setState(() {
                  categoriaSelecionada = value!;
                });
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _loading ? null : salvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF2E88),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Salvar',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}