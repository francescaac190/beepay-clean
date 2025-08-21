import 'package:flutter/material.dart';

class ResultadosScreen extends StatelessWidget {
  const ResultadosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultados')),
      body: const Center(
        child: Text('Aquí mostrarías los resultados de la búsqueda.'),
      ),
    );
  }
}
