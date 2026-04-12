import 'package:flutter/material.dart';

class AddTransacaoScreen extends StatefulWidget {
  const AddTransacaoScreen({super.key});

  @override
  State<AddTransacaoScreen> createState() => _AddTransacaoScreenState();
}

class _AddTransacaoScreenState extends State<AddTransacaoScreen> {
  final tituloController = TextEditingController();
  final valorController = TextEditingController();
  String categoriaSelecionada = 'Variáveis';

  void salvar() {
    if (tituloController.text.isEmpty || valorController.text.isEmpty) return;

    Navigator.pop(context, {
      'titulo': tituloController.text,
      'categoria': categoriaSelecionada,
      'valor': 'R\$ ${valorController.text}',
    });
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
              onPressed: salvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF2E88),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
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