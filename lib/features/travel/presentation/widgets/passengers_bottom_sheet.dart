// lib/features/travel/presentation/widgets/passengers_bottom_sheet.dart
import 'package:flutter/material.dart';
import '../../../../core/cores.dart'; // contiene los colors y textStyle que compartiste

class PassengersButton extends StatelessWidget {
  final int adults, kids, babies;
  final void Function(int, int, int) onConfirm;

  const PassengersButton({
    super.key,
    required this.adults,
    required this.kids,
    required this.babies,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _open(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: background2,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _chip(Icons.supervisor_account, adults),
            const SizedBox(width: 8),
            _chip(Icons.child_care, kids),
            const SizedBox(width: 8),
            _chip(Icons.stroller, babies),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, int v) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: gris7),
          const SizedBox(width: 3),
          Text('$v', style: bold(gris7, 14)),
        ],
      );

  void _open(BuildContext context) {
    int a = adults, k = kids, b = babies;
    const maxTotal = 9;

    int total() => a + k + b;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void incA() {
              if (total() < maxTotal) setModalState(() => a++);
            }

            void decA() {
              if (a > 1) setModalState(() => a--);
            }

            void incK() {
              if (total() < maxTotal) setModalState(() => k++);
            }

            void decK() {
              if (k > 0) setModalState(() => k--);
            }

            void incB() {
              if (total() < maxTotal) setModalState(() => b++);
            }

            void decB() {
              if (b > 0) setModalState(() => b--);
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Pasajeros', style: extraBold(blackBeePay, 20)),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Cantidad máxima de pasajeros: 9',
                        style: regular(gris6, 13)),
                  ),
                  const SizedBox(height: 16),
                  _rowStepper(
                    label: 'Adultos',
                    icon: Icons.supervisor_account,
                    value: a,
                    canDec: a > 1,
                    canInc: total() < maxTotal,
                    onDec: decA,
                    onInc: incA,
                  ),
                  _rowStepper(
                    label: 'Niños',
                    icon: Icons.child_care,
                    value: k,
                    canDec: k > 0,
                    canInc: total() < maxTotal,
                    onDec: decK,
                    onInc: incK,
                  ),
                  _rowStepper(
                    label: 'Bebés',
                    icon: Icons.stroller,
                    value: b,
                    canDec: b > 0,
                    canInc: total() < maxTotal,
                    onDec: decB,
                    onInc: incB,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: amber,
                        foregroundColor: blanco,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm(a, k, b);
                      },
                      child: Text('Aplicar', style: semibold(blanco, 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _rowStepper({
    required String label,
    required IconData icon,
    required int value,
    required bool canDec,
    required bool canInc,
    required VoidCallback onDec,
    required VoidCallback onInc,
  }) {
    final Color cDec = canDec ? gris7 : gris3;
    final Color cInc = canInc ? amber : gris3;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: gris7),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: semibold(blackBeePay, 16))),
          _circleIcon(Icons.remove_circle_outline, cDec, canDec ? onDec : null),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('$value', style: bold(blackBeePay, 16)),
          ),
          _circleIcon(Icons.add_circle_outline, cInc, canInc ? onInc : null),
        ],
      ),
    );
  }

  Widget _circleIcon(IconData icon, Color color, VoidCallback? onTap) {
    return InkResponse(
      onTap: onTap,
      radius: 18,
      child: Icon(icon, size: 22, color: color),
    );
  }
}
