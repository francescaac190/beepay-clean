import 'package:beepay/core/cores.dart';
import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _items = const [
    _CategoryData(
      title: 'BeeTravel',
      assetPath: 'assets/iconos/avion.png',
      keyName: 'travel',
    ),
    _CategoryData(
      title: 'BeeFun',
      assetPath: 'assets/iconos/attractions.png',
      keyName: 'fun',
    ),
    _CategoryData(
      title: 'BeeServices',
      assetPath: 'assets/iconos/lightbulb.png',
      keyName: 'services',
    ),
  ];

  void _onCategoryTap(_CategoryData item) {
    // TODO: navega o ejecuta la acción que quieras
    // Navigator.pushNamed(context, '/${item.keyName}');
    // o cualquier callback que uses
    debugPrint('Tap en categoría: ${item.title}');
  }

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Selecciona una categoría para ver las opciones disponibles',
              style: regular(gris7, 14),
            ),
          ),
          const SizedBox(height: 8),
          ..._items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CategoryCard(
                data: item,
                onTap: () => _onCategoryTap(item),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _CategoryData data;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        elevation: 0,
        color: blanco,
        surfaceTintColor: blanco,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            // Borde suave estilo screenshot
            color: (gris7).withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Icono desde assets
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: background2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  data.assetPath,
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  data.title,
                  style: medium(blackBeePay, 16),
                ),
              ),
              Icon(Icons.chevron_right, color: gris7),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryData {
  final String title;
  final String assetPath;
  final String keyName;

  const _CategoryData({
    required this.title,
    required this.assetPath,
    required this.keyName,
  });
}
