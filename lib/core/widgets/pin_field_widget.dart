import 'package:beepay/core/cores.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinFieldWidget extends StatelessWidget {
  const PinFieldWidget({
    super.key,
    required this.otpController,
  });

  final TextEditingController otpController;

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      length: 6,
      animationType: AnimationType.fade,
      keyboardType: TextInputType.number,
      controller: otpController,
      onChanged: (value) {},
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(5),
        activeColor: cupertinoGreen,
        selectedColor: cupertinoGreen,
        fieldHeight: 50,
        fieldWidth: 40,
        activeFillColor: Colors.white,
        inactiveColor: gris4,
      ),
    );
  }
}
