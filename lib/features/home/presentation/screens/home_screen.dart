import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cores.dart';
import '../widgets/saldo_widget.dart';
import '../widgets/perfil_widget.dart';
import '../widgets/carousel_widget.dart';
import '../widgets/transferir_recargar_widget.dart';
import '../widgets/dudas_consultas_widget.dart';
import '../bloc/perfil_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<PerfilBloc>().add(GetPerfilEvent()); // recarga perfil
        await Future.delayed(const Duration(milliseconds: 250));
      },
      color: amber,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(flex: 2, child: PerfilWidget()),
                SizedBox(width: 12),
                Expanded(flex: 2, child: SaldoWidget()),
              ],
            ),
            addVerticalSpace(16),
            CustomButton(
              text: 'Pagar con BeePay',
              onPressed: () => debugPrint('pagars'),
              width: double.infinity,
              height: 45,
              color: amber,
              textColor: blanco,
            ),
            addVerticalSpace(16),
            const TransferirRecargarWidget(),
            addVerticalSpace(16),
            SizedBox(width: double.infinity, child: CarouselWidget()),
            addVerticalSpace(24),
            const DudasConsultasWidget(),
            addVerticalSpace(36),
          ],
        ),
      ),
    );
  }
}
