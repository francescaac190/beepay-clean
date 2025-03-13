import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cores.dart';
import '../bloc/perfil_bloc.dart';

class PerfilWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PerfilBloc, PerfilState>(
      builder: (context, state) {
        if (state is PerfilLoading) {
          return CircularProgressIndicator(); // Muestra carga mientras se obtiene el perfil
        } else if (state is PerfilLoaded) {
          return _buildPerfil(
              state); // Construye la UI con los datos del usuario
        } else {
          return Text('Error al cargar perfil');
        }
      },
    );
  }

  Widget _buildPerfil(PerfilLoaded state) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(state.perfil.fotoPerfil),
            ),
            Spacer(),
            Text(
              'Bienvenido, \n${state.perfil.name}',
              style: medium(blackBeePay, 14),
            ),
          ],
        ),
      ),
    );
  }
}
