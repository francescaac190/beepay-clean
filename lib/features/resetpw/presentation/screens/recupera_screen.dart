import 'package:beepay/core/services/filesystem_manager.dart';
import 'package:beepay/features/resetpw/presentation/screens/otp_ver_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:beepay/injection_container.dart';
import '../../../../core/cores.dart';
import '../bloc/recupera_bloc.dart';
import '../../../../core/widgets/custom_button.dart';

class RecuperaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background2,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: const <Widget>[
              BackMethodWidget(),
              NewPasswordWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class NewPasswordWidget extends StatefulWidget {
  const NewPasswordWidget({Key? key}) : super(key: key);

  @override
  State<NewPasswordWidget> createState() => _NewPasswordWidgetState();
}

class _NewPasswordWidgetState extends State<NewPasswordWidget> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController emailCuentaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RecuperaBloc>(),
      child: BlocConsumer<RecuperaBloc, RecuperaState>(
        listener: (context, state) {
          if (state is Recupera) {
            cerrarDialogoCargando(context);
            Mensaje(context, state.message);
            FileSystemManager.instance.otp = state.token;
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => OtpCheck(
                    email: emailController.text, tipo: 'recuperar_contrasena'),
              ),
            );
          } else if (state is RecuperaCuenta) {
            cerrarDialogoCargando(context);
            Mensaje(context, state.message);
            FileSystemManager.instance.otp = state.codigo;

            print('bien recupera cuenta');
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => OtpCheck(
                    email: emailCuentaController.text,
                    tipo: 'verificar_cuenta'),
              ),
            );
          } else if (state is RecuperaLoading) {
            dialogCargando(context, true);
          } else if (state is RecuperaError) {
            cerrarDialogoCargando(context);
            MensajeError(context, state.message);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      addVerticalSpace(16),
                      Center(
                        child: Icon(
                          Icons.key,
                          color: gris7,
                          size: 40,
                        ),
                      ),
                      addVerticalSpace(8),
                      Center(
                        child: Text(
                          'RECUPERA TU CONTRASEÑA',
                          style: semibold(gris7, 15),
                        ),
                      ),
                      addVerticalSpace(16),
                      Text(
                        'Ingresá tu email asociado:',
                        textAlign: TextAlign.left,
                        style: regular(gris7, 15),
                      ),
                      addVerticalSpace(4),
                      CustomTextFormField(
                        emailController,
                        TextInputType.emailAddress,
                        TextCapitalization.none,
                        false,
                        ' ',
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresá tu email asociado';
                          }
                          return null;
                        },
                        null,
                      ),
                      addVerticalSpace(16),
                      CustomButton(
                        text: 'Recuperar Contraseña',
                        textColor: blanco,
                        height: 50,
                        width: double.infinity,
                        color: amber,
                        onPressed: () {
                          if (emailController.text.isNotEmpty) {
                            BlocProvider.of<RecuperaBloc>(context).add(
                              RecuperaaEvent(emailController.text),
                            );
                          } else {
                            MensajeError(
                                context, 'No se aceptan espacios vacios.');
                          }
                        },
                      ),
                      addVerticalSpace(16),
                      Divider(),
                      Center(
                        child: Icon(
                          Icons.account_circle,
                          color: gris4,
                          size: 40,
                        ),
                      ),
                      addVerticalSpace(8),
                      Center(
                        child: Text(
                          'RECUPERA TU CUENTA',
                          style: semibold(gris7, 15),
                        ),
                      ),
                      addVerticalSpace(16),
                      Text(
                        'Ingresá tu email asociado:',
                        textAlign: TextAlign.left,
                        style: regular(gris7, 16),
                      ),
                      addVerticalSpace(4),
                      CustomTextFormField(
                        emailCuentaController,
                        TextInputType.emailAddress,
                        TextCapitalization.none,
                        false,
                        ' ',
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresá tu email asociado';
                          }
                          return null;
                        },
                        null,
                      ),
                      addVerticalSpace(16),
                      CustomButton(
                        text: 'Recuperar Cuenta',
                        textColor: blanco,
                        height: 50,
                        width: double.infinity,
                        color: amber,
                        onPressed: () {
                          if (emailCuentaController.text.isNotEmpty) {
                            BlocProvider.of<RecuperaBloc>(context).add(
                              RecuperaCuentaEvent(emailCuentaController.text),
                            );
                          } else {
                            MensajeError(
                                context, 'No se aceptan espacios vacios.');
                          }
                        },
                      ),
                      addVerticalSpace(16),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
