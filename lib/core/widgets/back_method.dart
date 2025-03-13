import 'package:beepay/core/cores.dart';
import 'package:flutter/material.dart';

class BackMethodWidget extends StatelessWidget {
  const BackMethodWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Image.asset(
            "assets/iconos/Bee-pay-big.png",
            height: 100,
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: amber,
              size: 30,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}
