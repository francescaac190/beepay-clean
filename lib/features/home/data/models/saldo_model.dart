import '../../domain/entities/saldo_entity.dart';

class SaldoModel extends SaldoEntity {
  SaldoModel({required double saldo}) : super(saldo: saldo);

  factory SaldoModel.fromJson(Map<String, dynamic> json) {
    // Accedemos al saldo dentro de "data"
    return SaldoModel(
      saldo: (json['data'] != null && json['data'].isNotEmpty)
          ? json['data'][0]['saldo'].toDouble()
          : 0.0, // Si no hay datos, devuelve 0.0
    );
  }
}
