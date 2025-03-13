import 'package:beepay/core/cores.dart';
import 'package:beepay/features/home/presentation/bloc/saldo_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SaldoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 150,
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 7,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: BlocBuilder<SaldoBloc, SaldoState>(
          builder: (context, state) {
            if (state is SaldoLoading) {
              return Center(child: CircularProgressIndicator(color: amber));
            } else if (state is SaldoLoaded) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/iconos/moneda.png',
                    height: 50,
                  ),
                  addVerticalSpace(16),
                  Text(
                    '${state.saldo.saldo}\nBeePuntos',
                    textAlign: TextAlign.center,
                    style: semibold(blackBeePay, 15),
                  ),
                ],
              );
            } else if (state is SaldoError) {
              return Center(
                child: Text(
                  "Error al cargar saldo",
                  style: semibold(Colors.red, 14),
                ),
              );
            }
            return Center(
              child: Text(
                "Saldo no disponible",
                style: semibold(blackBeePay, 15),
              ),
            );
          },
        ),
      ),
    );
  }
}
