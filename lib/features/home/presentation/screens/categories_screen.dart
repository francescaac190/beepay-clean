import 'package:beepay/core/cores.dart';
import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: background2,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Categorías', style: semibold(blackBeePay, 20)),
          centerTitle: false,
          backgroundColor: blanco,
          surfaceTintColor: blanco,
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Selecciona una categoría para ver las opciones disponibles',
                style: regular(gris7, 14),
              ),
            ),
            // Aquí puedes agregar tus categorías como botones o tarjetas
            ListTile(
              title: Text('Categoría 1', style: medium(blackBeePay, 16)),
              onTap: () {
                // Acción al seleccionar la categoría
              },
            ),
            ListTile(
              title: Text('Categoría 2', style: medium(blackBeePay, 16)),
              onTap: () {
                // Acción al seleccionar la categoría
              },
            ),
            // Agrega más categorías según sea necesario
          ],
        ));
  }
}
