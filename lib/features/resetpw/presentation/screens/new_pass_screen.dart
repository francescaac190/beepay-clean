import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:beepay/core/cores.dart';
import 'package:beepay/injection_container.dart';
import '../bloc/recupera_bloc.dart';

class NewPass extends StatefulWidget {
  final String email;
  final String verificacion;

  const NewPass({required this.email, required this.verificacion, Key? key})
      : super(key: key);

  @override
  _NewPassState createState() => _NewPassState();
}

class _NewPassState extends State<NewPass> {
  final TextEditingController nuevapw = TextEditingController();
  final TextEditingController confirmpw = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RecuperaBloc>(),
      child: Scaffold(
        backgroundColor: background2,
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<RecuperaBloc, RecuperaState>(
            listener: (context, state) {
              if (state is RecuperaLoading) {
                dialogCargando(context, false);
              } else if (state is ActualizaPass) {
                cerrarDialogoCargando(context);
                Mensaje(context, state.message);
                Future.delayed(Duration(seconds: 2), () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                });
              } else if (state is RecuperaError) {
                cerrarDialogoCargando(context);
                MensajeError(context, state.message);
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    BackMethodWidget(),
                    addVerticalSpace(16),
                    Container(
                      padding: EdgeInsets.all(24),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 0,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Text('Ingrese su nueva contraseña',
                                style: semibold(gris7, 16)),
                            addVerticalSpace(16),
                            _buildPasswordField(nuevapw, "Nueva contraseña"),
                            addVerticalSpace(16),
                            _buildPasswordField(
                                confirmpw, "Confirmar contraseña"),
                            addVerticalSpace(32),
                            CustomButton(
                              text: 'Cambiar contraseña',
                              textColor: blanco,
                              color: amber,
                              width: double.infinity,
                              height: 45,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  if (nuevapw.text == confirmpw.text) {
                                    BlocProvider.of<RecuperaBloc>(context).add(
                                      ActualizaPassEvent(
                                          widget.email,
                                          widget.verificacion,
                                          nuevapw.text,
                                          confirmpw.text),
                                    );
                                  } else {
                                    Mensaje(context,
                                        'Las contraseñas deben ser iguales');
                                  }
                                } else {
                                  Mensaje(
                                      context, 'No se aceptan campos vacíos.');
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      TextEditingController controller, String hintText) {
    return TextFormField(
      obscureText: _obscureText,
      controller: controller,
      cursorColor: gris7,
      decoration: InputDecoration(
        icon: Icon(Icons.lock, color: gris7),
        hintText: hintText,
        hintStyle: medium(gris7, 15),
        border: UnderlineInputBorder(
            borderSide: BorderSide(color: gris7, width: 1)),
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: gris7, width: 1)),
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: gris7, width: 1)),
        suffixIcon: GestureDetector(
          onTap: _toggle,
          child: Icon(
              _obscureText
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              size: 24,
              color: Colors.black54),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresá tu contraseña';
        }
        if (value.length < 8) {
          return 'La contraseña debe tener al menos 8 caracteres';
        }
        return null;
      },
    );
  }
}
