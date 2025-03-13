import 'package:flutter/material.dart';
import '../../../../core/cores.dart';
import '../widgets/saldo_widget.dart';
import '../widgets/perfil_widget.dart';
import '../widgets/carousel_widget.dart';
import '../widgets/transferir_recargar_widget.dart';
import '../widgets/dudas_consultas_widget.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        print("Recargando datos...");
      },
      color: amber,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                PerfilWidget(),
                addHorizontalSpace(12),
                SaldoWidget(),
              ],
            ),
            addVerticalSpace(16),
            CustomButton(
              text: 'Pagar con BeePay',
              onPressed: () {
                print('pagars');
              },
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
