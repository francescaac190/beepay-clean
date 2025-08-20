// lib/features/home/presentation/widgets/perfil_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cores.dart';
import '../bloc/perfil_bloc.dart';

class PerfilWidget extends StatelessWidget {
  const PerfilWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
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
      child: BlocBuilder<PerfilBloc, PerfilState>(
        builder: (context, state) {
          // INITIAL y LOADING -> skeleton
          if (state is PerfilInitial || state is PerfilLoading) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 30, backgroundColor: background2),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14, width: 140, color: background2),
                      const SizedBox(height: 8),
                      Container(height: 12, width: 100, color: background2),
                      const Spacer(),
                      Container(height: 10, width: 80, color: background2),
                    ],
                  ),
                ),
              ],
            );
          }

          // ERROR -> mensaje + reintentar
          if (state is PerfilError) {
            return Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Error al cargar perfil', maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                
              ],
            );
          }

          // LOADED
          final perfil = (state as PerfilLoaded).perfil;
          final fullName = '${perfil.name} ${perfil.apellido}'.trim();
          final foto = perfil.fotoPerfil; // puede ser '' si no hay foto

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _AvatarFotoONombre(foto: foto, nombre: fullName),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        const SizedBox(height: 4),
                        
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'Bienvenido,\n${perfil.name.isNotEmpty ? perfil.name : 'Usuario'}',
                style: medium(blackBeePay, 14),
              ),
            ],
          );
        },
      ),
    );
  }
}
class _AvatarFotoONombre extends StatelessWidget {
  final String foto;
  final String nombre;
  const _AvatarFotoONombre({required this.foto, required this.nombre});

  @override
  Widget build(BuildContext context) {
    if (foto.isNotEmpty) {
      return CircleAvatar(
        radius: 30,
        backgroundColor: background2,
        backgroundImage: NetworkImage(foto),
        onBackgroundImageError: (_, __) {}, // evita crash si la URL falla
      );
    }
    // fallback con iniciales
    final parts = nombre.trim().split(RegExp(r'\s+'));
    final a = parts.isNotEmpty ? parts.first.characters.first : '';
    final b = parts.length > 1 ? parts.last.characters.first : '';
    final initials = (a + b).isNotEmpty ? (a + b).toUpperCase() : 'BP';
    return CircleAvatar(
      radius: 30,
      backgroundColor: background2,
      child: Text(initials, style: semibold(blackBeePay, 16)),
    );
  }
}
