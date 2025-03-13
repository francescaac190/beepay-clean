import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:beepay/injection_container.dart';
import '../../../../core/cores.dart';
import '../bloc/register_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpScreen extends StatefulWidget {
  final String name;
  final String apellido;
  final String cel;
  final String ci;
  final String email;
  final String password;
  final String password_confirmation;
  final String codigo;
  OtpScreen(
      {required this.email,
      required this.name,
      required this.apellido,
      required this.cel,
      required this.ci,
      required this.password,
      required this.password_confirmation,
      required this.codigo});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _sendOtpOnEnter();
  }

  void _sendOtpOnEnter() {
    BlocProvider.of<RegisterBloc>(context).add(SendOtpEvent(widget.email));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RegisterBloc>(),
      child: Scaffold(
        backgroundColor: background2,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Stack(
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
                ),
                PinContainer(
                    formKey: _formKey,
                    otpController: otpController,
                    widget: widget),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PinContainer extends StatefulWidget {
  const PinContainer({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.otpController,
    required this.widget,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;
  final TextEditingController otpController;
  final OtpScreen widget;

  @override
  State<PinContainer> createState() => _PinContainerState();
}

class _PinContainerState extends State<PinContainer> {
  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 180;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 7,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Form(
        key: widget._formKey,
        child: Column(
          children: [
            Center(
              child: Text(
                'Verifica tu correo electrónico',
                style: semibold(blackBeePay, 20),
              ),
            ),
            addVerticalSpace(12),
            Container(
              padding: EdgeInsets.only(left: 5),
              child: Text(
                'Ingresá el código enviado por correo para validar la cuenta',
                textAlign: TextAlign.center,
                style: medium(gris7, 15),
              ),
            ),
            addVerticalSpace(24),
            PinFieldWidget(otpController: widget.otpController),
            addVerticalSpace(24),
            _timeWidget(),
            addVerticalSpace(24),
            BlocConsumer<RegisterBloc, RegisterState>(
              listener: (context, state) {
                if (state is RegisterOtpVerified) {
                  BlocProvider.of<RegisterBloc>(context).add(RegisterUserEvent({
                    "name": widget.widget.name,
                    "apellido": widget.widget.apellido,
                    "cel": widget.widget.cel,
                    "ci": widget.widget.ci,
                    'email': widget.widget.email,
                    "password": widget.widget.password,
                    "password_confirmation":
                        widget.widget.password_confirmation,
                    "codigo": widget.widget.codigo
                  }));
                } else if (state is RegisterCompleted) {
                  cerrarDialogoCargando(context);

                  Mensaje(context, "${state.message}. Redirigiendo...");
                  Future.delayed(Duration(seconds: 3), () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (route) => false);
                  });
                } else if (state is RegisterLoading) {
                  dialogCargando(context, true);
                } else if (state is RegisterError) {
                  cerrarDialogoCargando(context);

                  MensajeError(context, state.message);
                }
              },
              builder: (context, state) {
                return CustomButton(
                  text: "Validar cuenta",
                  onPressed: () {
                    if (widget._formKey.currentState!.validate()) {
                      BlocProvider.of<RegisterBloc>(context).add(
                        VerifyOtpEvent(
                            widget.widget.email, widget.otpController.text),
                      );
                    }
                  },
                  color: amber,
                  textColor: blanco,
                  width: double.infinity,
                  height: 50,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeWidget() {
    return CountdownTimer(
      endTime: endTime,
      textStyle: regular(blackBeePay, 18),
      endWidget: TextButton(
        onPressed: () {
          setState(() {
            BlocProvider.of<RegisterBloc>(context)
                .add(SendOtpEvent(widget.widget.email));
            endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 180;
          });
        },
        child: Column(
          children: [
            Text(
              'El tiempo de espera expiró ',
              style: regular(blackBeePay, 17),
            ),
            addVerticalSpace(8),
            Text(
              'Reenviar código',
              style: semibold(amber, 18),
            ),
          ],
        ),
      ),
    );
  }
}
