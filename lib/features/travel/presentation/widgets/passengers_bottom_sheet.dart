import 'package:flutter/material.dart';

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
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F7),
          borderRadius: BorderRadius.circular(28),
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

  Widget _chip(IconData icon, int v) => Row(children: [
        Icon(icon, size: 16, color: Colors.grey.shade700),
        const SizedBox(width: 3),
        Text('$v', style: const TextStyle(fontWeight: FontWeight.w700)),
      ]);

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
            void incA() { if (total() < maxTotal) setModalState(() => a++); }
            void decA() { if (a > 1) setModalState(() => a--); }
            void incK() { if (total() < maxTotal) setModalState(() => k++); }
            void decK() { if (k > 0) setModalState(() => k--); }
            void incB() { if (total() < maxTotal) setModalState(() => b++); }
            void decB() { if (b > 0) setModalState(() => b--); }

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Pasajeros', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 6),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Cantidad máxima de pasajeros: 9', style: TextStyle(color: Colors.black54)),
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
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm(a, k, b);
                      },
                      child: const Text('Aplicar', style: TextStyle(fontWeight: FontWeight.w800)),
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
    Color cDec = canDec ? Colors.black54 : Colors.black26;
    Color cInc = canInc ? Colors.amber : Colors.black26;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade700),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          _circleIcon(Icons.remove_circle_outline, cDec, canDec ? onDec : null),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('$value', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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
