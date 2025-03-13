import 'package:beepay/core/cores.dart';
import 'package:flutter/material.dart';

Center LoadingWidget() {
  return Center(
    child: Image.asset(
      'assets/iconos/Loader-beepay.gif',
      height: 100,
    ),
  );
}

Future<void> dialogCargando(BuildContext context, bool dismissible) async {
  showDialog<void>(
    context: context,
    barrierDismissible:
        dismissible, // No permitir que el usuario lo cierre manualmente
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: blanco,
        surfaceTintColor: blanco,
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              LoadingWidget(), // Indicador de carga
              SizedBox(height: 10),
              Center(
                child: Text(
                  'Cargando...',
                  textAlign: TextAlign.center,
                  style: medium(blackBeePay, 16),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void cerrarDialogoCargando(BuildContext context) {
  if (Navigator.of(context, rootNavigator: false).canPop()) {
    Navigator.of(context, rootNavigator: false).pop();
  }
}

void Mensaje(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: blanco,
      behavior: SnackBarBehavior.floating,
      showCloseIcon: true,
      margin: EdgeInsets.all(10),
      content: Text(
        mensaje,
        style: medium(blackBeePay, 14),
      ),
    ),
  );
}

void MensajeError(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: rojo,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(10),
      content: Text(
        mensaje,
        style: medium(blanco, 14),
      ),
    ),
  );
}

TextFormField CustomTextFormField(
    TextEditingController textController,
    TextInputType textInputType,
    TextCapitalization textCap,
    bool obscureText,
    String hintText,
    String? Function(String?)? validator,
    Widget? suffix) {
  return TextFormField(
    controller: textController,
    keyboardType: textInputType,
    textCapitalization: textCap,
    obscureText: obscureText,
    autocorrect: false,
    onTapOutside: (event) {
      FocusManager.instance.primaryFocus?.unfocus();
    },
    style: regular(blackBeePay, 16),
    decoration: InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      hintText: hintText,
      constraints: BoxConstraints(
        maxHeight: 50,
      ),
      hintStyle: regular(gris2, 15),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: background2,
      suffixIcon: suffix,
    ),
    validator: validator,
  );
}

showDataAlert(String titulo, String contenido, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        surfaceTintColor: blanco,
        backgroundColor: blanco,
        insetPadding: EdgeInsets.all(16),
        contentPadding: EdgeInsets.all(20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(
              20.0,
            ),
          ),
        ),
        title: Text(
          titulo,
          style: medium(blackBeePay, 18),
        ),
        content: Text(
          contenido,
          textAlign: TextAlign.justify,
          style: regular(blackBeePay, 15),
        ),
      );
    },
  );
}
