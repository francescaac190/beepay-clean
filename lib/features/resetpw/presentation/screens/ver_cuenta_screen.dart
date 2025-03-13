import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cores.dart';
import '../../../../injection_container.dart';
import '../bloc/recupera_bloc.dart';

class VerCuentaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>?;

    if (args == null || !args.containsKey('telefono')) {
      return ErrorScreen(message: "No se recibió información del usuario.");
    }

    final telefono = args['telefono']!;

    return BlocProvider(
      create: (context) => sl<RecuperaBloc>(),
      child: Scaffold(
        backgroundColor: background2,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<RecuperaBloc, RecuperaState>(
            builder: (context, state) {
              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    BackMethodWidget(),
                    addVerticalSpace(24),
                    _InfoUsuario(telefono: telefono),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _InfoUsuario extends StatelessWidget {
  const _InfoUsuario({
    super.key,
    required this.telefono,
  });

  final String telefono;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
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
        children: [
          Center(
            child: Icon(
              Icons.account_circle,
              color: gris7,
              size: 50,
            ),
          ),
          addVerticalSpace(8),
          Center(
            child: Text(
              'RECUPERA TU CUENTA',
              style: semibold(gris4, 16),
            ),
          ),
          addVerticalSpace(32),
          Text(
            'Tu número para ingresar a BeePay:',
            style: regular(gris4, 16),
            textAlign: TextAlign.center,
          ),
          addVerticalSpace(16),
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: background2,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              telefono,
              textAlign: TextAlign.center,
              style: medium(blackBeePay, 25),
            ),
          ),
          addVerticalSpace(32),
          CustomButton(
            text: 'Volver al inicio',
            textColor: blanco,
            color: amber,
            height: 45,
            width: double.infinity,
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
          ),
          addVerticalSpace(24),
        ],
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String message;
  const ErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          message,
          style: bold(Colors.red, 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
