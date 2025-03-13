import 'package:beepay/core/services/filesystem_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cores.dart';
import '../../../../injection_container.dart';
import '../bloc/recupera_bloc.dart';

class OtpCheck extends StatefulWidget {
  final String email;
  final String tipo; // "recuperar_contrasena" o "verificar_cuenta"

  const OtpCheck({Key? key, required this.email, required this.tipo})
      : super(key: key);

  @override
  State<OtpCheck> createState() => _OtpCheckState();
}

class _OtpCheckState extends State<OtpCheck> {
  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print(widget.email);
    print(widget.tipo);

    return BlocProvider(
      create: (context) => sl<RecuperaBloc>(),
      child: Scaffold(
        backgroundColor: background2,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: <Widget>[
                BackMethodWidget(),
                PinFieldContainer(
                  tipo: widget.tipo,
                  otpController: otpController,
                  email: widget.email,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PinFieldContainer extends StatelessWidget {
  const PinFieldContainer({
    super.key,
    required this.tipo,
    required this.otpController,
    required this.email,
  });

  final String tipo;
  final TextEditingController otpController;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 20, 10, 10),
      padding: EdgeInsets.fromLTRB(20, 50, 20, 0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 7,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: BlocConsumer<RecuperaBloc, RecuperaState>(
        listener: (context, state) {
          if (state is VerificaCod) {
            cerrarDialogoCargando(context);
            Mensaje(context, state.message);

            if (tipo == "verificar_cuenta") {
              Navigator.pushNamed(context, '/ver_cuenta',
                  arguments: {'telefono': state.telefono});
            }
          } else if (state is RecuperaLoading) {
            dialogCargando(context, true);
          } else if (state is RecuperaError) {
            cerrarDialogoCargando(context);
            MensajeError(context, state.message);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Center(
                child: Icon(
                  Icons.account_circle,
                  color: gris7,
                  size: 40,
                ),
              ),
              addVerticalSpace(8),
              Center(
                child: Text(
                  'RECUPERA TU CUENTA',
                  style: semibold(gris4, 16),
                ),
              ),
              addVerticalSpace(24),
              Text(
                'Ingresá el código enviado a tu email:',
                textAlign: TextAlign.center,
                style: regular(gris4, 16),
              ),
              addVerticalSpace(24),
              PinFieldWidget(otpController: otpController),
              SizedBox(height: 20),
              CustomButton(
                text: 'Verificar',
                textColor: blanco,
                color: amber,
                width: double.infinity,
                height: 45,
                onPressed: () {
                  if (otpController.text.isNotEmpty) {
                    if (otpController.text == FileSystemManager.instance.otp) {
                      if (tipo == "recuperar_contrasena") {
                        Navigator.pushNamed(
                          context,
                          '/reset_password',
                          arguments: {
                            'email': email,
                            'verificacion': otpController.text,
                          },
                        );
                      } else {
                        BlocProvider.of<RecuperaBloc>(context).add(
                          VerificaCodEvent(email, otpController.text),
                        );
                      }
                    } else {
                      MensajeError(context, 'Código incorrecto');
                    }
                  } else {
                    MensajeError(context, 'No se aceptan espacios vacíos');
                  }
                },
              ),
              addVerticalSpace(32),
            ],
          );
        },
      ),
    );
  }
}
