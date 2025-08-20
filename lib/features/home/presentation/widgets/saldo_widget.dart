import 'package:beepay/core/cores.dart';
import 'package:beepay/features/home/presentation/bloc/saldo_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SaldoWidget extends StatelessWidget {
  const SaldoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150, // igual que PerfilWidget
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: blanco,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BlocBuilder<SaldoBloc, SaldoState>(
        builder: (context, state) {
          if (state is SaldoLoading) {
            return Center(child: CircularProgressIndicator(color: amber));
          }

          if (state is SaldoLoaded) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // usa tu asset de moneda
                Image.asset(
                  'assets/iconos/moneda.png', // ajusta la ruta si tu asset está en otra carpeta
                  height: 48,
                  width: 48,
                ),
                const SizedBox(height: 10), // reducido para evitar overflow
                Flexible(
                  child: Text(
                    '${state.saldo.saldo}\nBeePuntos',
                    textAlign: TextAlign.center,
                    maxLines: 2, // evita desborde vertical
                    overflow: TextOverflow.ellipsis,
                    style: semibold(blackBeePay, 15).copyWith(height: 1.2),
                  ),
                ),
              ],
            );
          }

          if (state is SaldoError) {
            return Center(
              child: Text(
                'Error al cargar saldo',
                textAlign: TextAlign.center,
                style: semibold(Colors.red, 14),
              ),
            );
          }

          return Center(
            child: Text(
              'Saldo no disponible',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: semibold(blackBeePay, 15),
            ),
          );
        },
      ),
    );
  }
}
