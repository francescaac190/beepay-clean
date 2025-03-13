import 'package:flutter/material.dart';

import '../../../../core/cores.dart';

class TransferirRecargarWidget extends StatelessWidget {
  const TransferirRecargarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 7,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MaterialButton(
            onPressed: () {
              Navigator.pushNamed(context, '/trans2');
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(height: 60, 'assets/iconos/icono-transferir 2.png'),
                Text(
                  'Transferir',
                  style: medium(blackBeePay, 15),
                )
              ],
            ),
          ),
          addVerticalSpace(16),
          MaterialButton(
            onPressed: () {
              Navigator.pushNamed(context, '/recargar1');
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(height: 60, 'assets/iconos/icono-recargar.png'),
                Text(
                  'Recargar',
                  style: medium(blackBeePay, 15),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
