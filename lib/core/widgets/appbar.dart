import 'package:flutter/material.dart';

import '../cores.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      iconTheme: IconThemeData(color: amber),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      foregroundColor: blanco,
      centerTitle: true,
      title: Container(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          'assets/JUST BEE LOGO OK-03 - copia.png',
          fit: BoxFit.contain,
          height: 45,
        ),
      ),
    );
  }
}
