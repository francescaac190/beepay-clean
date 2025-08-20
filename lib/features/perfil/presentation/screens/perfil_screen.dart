// 📄 features/home/presentation/pages/perfil_page.dart
import 'package:beepay/core/cores.dart';
import 'package:beepay/core/widgets/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/styles/colors.dart';
import '../../../home/domain/entities/perfil_entity.dart';
import '../../../home/presentation/bloc/perfil_bloc.dart';

import 'package:beepay/injection_container.dart' show sl;

import '../../../home/presentation/bloc/saldo_bloc.dart';

class PerfilScaffold extends StatelessWidget {
  const PerfilScaffold();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: blanco,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: background2,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                BlocBuilder<PerfilBloc, PerfilState>(
                  builder: (context, state) {
                    if (state is PerfilLoading || state is PerfilInitial) {
                      return const _PerfilCard.loading();
                    }
                    if (state is PerfilError) {
                      return _ErrorBox(message: state.message);
                    }
                    if (state is PerfilLoaded) {
                      final p = state.perfil;
                      return Column(
                        children: [
                          // if (p.completo == false) _CompletaPerfilTile(),
                          addVerticalSpace(24),
                          _PerfilHeader(perfil: p),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                addVerticalSpace(10),
                _PuntosCard(),
                addVerticalSpace(10),
                const _OpcionesPerfilList(),
                addVerticalSpace(20),
                const _DesactivarCuentaButton(),
                addVerticalSpace(16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===================== Widgets Perfil =====================
class _CompletaPerfilTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/pasos')
          .then((_) => context.read<PerfilBloc>().add(GetPerfilEvent())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.08),
              blurRadius: 4.0,
              spreadRadius: 0.0,
              offset: Offset(0.0, 0.0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Completa tu Perfil', style: semibold(blackBeePay, 18)),
            Container(
              height: 47,
              width: 47,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_forward_ios,
                  size: 20, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerfilHeader extends StatelessWidget {
  final Perfil perfil;
  const _PerfilHeader({required this.perfil});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 62),
            padding: const EdgeInsets.only(top: 62, bottom: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.08),
                  blurRadius: 4.0,
                  spreadRadius: 0.0,
                  offset: Offset(0.0, 0.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('${perfil.name} ${perfil.apellido}',
                    style: semibold(blackBeePay, 20)),
                addVerticalSpace(8),
                Text(perfil.email ?? '', style: regular(blackBeePay, 16)),
                addVerticalSpace(5),
                Text(perfil.cel ?? '', style: regular(blackBeePay, 16)),
              ],
            ),
          ),
          Positioned(
            child: Container(
              height: 124,
              width: 124,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(62),
              ),
              child: CircleAvatar(
                radius: 62,
                backgroundColor: blanco,
                backgroundImage: (
                        // perfil.completo &&
                        (perfil.fotoPerfil?.isNotEmpty ?? false))
                    ? NetworkImage(perfil.fotoPerfil!)
                    : const AssetImage('assets/iconos/icono-perfil-mediano.png')
                        as ImageProvider,
              ),
            ),
          ),
          // if (perfil.completo)
          //   Positioned(
          //     right: 10,
          //     top: 70,
          //     child: CircleAvatar(
          //       radius: 20,
          //       backgroundColor: kGrey200,
          //       child: InkWell(
          //         onTap: () => Navigator.pushNamed(context, '/aa')
          //             .then((_) => context.read<PerfilBloc>().add(GetPerfilEvent())),
          //         child: const Icon(Icons.edit, size: 22, color: Colors.black54),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}

class _PerfilCard extends StatelessWidget {
  final bool isLoading;
  const _PerfilCard({this.isLoading = false});
  const _PerfilCard.loading() : isLoading = true;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    return const SizedBox.shrink();
  }
}

// ===================== Puntos / Saldo =====================
class _PuntosCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        color: blanco,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 4.0,
            spreadRadius: 0.0,
            offset: Offset(0.0, 0.0),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BlocBuilder<SaldoBloc, SaldoState>(
            builder: (context, state) {
              if (state is SaldoLoading || state is SaldoInitial) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PUNTOS BEEPAY', style: semibold(gris6, 14)),
                    addVerticalSpace(8),
                    Row(
                      children: [
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        addVerticalSpace(8),
                        const SizedBox(width: 8),
                        Text('Cargando…', style: regular(blackBeePay, 16)),
                      ],
                    ),
                  ],
                );
              }
              if (state is SaldoError) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PUNTOS BEEPAY', style: semibold(gris6, 14)),
                    addVerticalSpace(8),
                    Text('Error: ${state.message}',
                        style: regular(Colors.red, 14)),
                  ],
                );
              }
              if (state is SaldoLoaded) {
                final puntos = state.saldo; // double
                final formatted = NumberFormat.decimalPatternDigits(
                  locale: 'en_US',
                  decimalDigits: 2,
                ).format(puntos.saldo);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PUNTOS BEEPAY', style: semibold(gris6, 14)),
                    addVerticalSpace(8),
                    Text('$formatted \nBeePuntos',
                        textAlign: TextAlign.left,
                        style: medium(blackBeePay, 30)),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Logo de categoría (si lo traes en PerfilLoaded):
          BlocBuilder<PerfilBloc, PerfilState>(
            builder: (context, state) {
              String? logo;
              if (state is PerfilLoaded) {
                logo = state.perfil.logoCategoria;
              }
              return Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: background2,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: ClipOval(
                  child: (logo != null && logo.isNotEmpty)
                      ? Image.network(logo,
                          height: 64, width: 64, fit: BoxFit.cover)
                      : const SizedBox(height: 64, width: 64),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ===================== Lista de opciones =====================
class _OpcionesPerfilList extends StatelessWidget {
  const _OpcionesPerfilList();

  @override
  Widget build(BuildContext context) {
    Widget tile(String title, String route) => InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 19),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: medium(blackBeePay, 16)),
                const Icon(Icons.arrow_forward_ios, size: 20),
              ],
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: blanco,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 4.0,
            spreadRadius: 0.0,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          tile('Información de perfil', '/info'),
          dividerWidget(),
          tile('Cambiar código operacional', '/facturasinfo'),
          dividerWidget(),
          tile('Datos de facturación', '/facturasinfo'),
          dividerWidget(),
          tile('Tus contactos', '/contactosfavoritos'),
          dividerWidget(),
          tile('Referidos (Próximamente)', '/Referidos'),
          dividerWidget(),
          tile('Tus intereses', '/infoIntereses'),
          dividerWidget(),
          tile('Biometría', '/biometria'),
          dividerWidget(),
          tile('Convertite en BeePartner', '/facturasinfo'),
          dividerWidget(),
          tile('Contáctanos', '/solicitar'),
          dividerWidget(),
          tile('Términos y Condiciones', '/facturasinfo'),
          dividerWidget(),
          tile('Sobre BeePay', '/solicitar'),
          dividerWidget(),
          tile('Cerrar sesión', '/solicitar'),
        ],
      ),
    );
  }

  Divider dividerWidget() {
    return const Divider(
      color: gris2,
      indent: 8,
      endIndent: 8,
    );
  }
}

// ===================== Desactivar cuenta =====================
class _DesactivarCuentaButton extends StatelessWidget {
  const _DesactivarCuentaButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: gris4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () => _showDeactivateDialog(context),
        child: Text('Desactivar cuenta', style: semibold(blanco, 20)),
      ),
    );
  }

  Future<void> _showDeactivateDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: blanco,
        surfaceTintColor: blanco,
        title:
            Text('Desactivación de cuenta', style: semibold(blackBeePay, 18)),
        content: Text('¿Estás seguro que querés desactivar tu cuenta?',
            style: regular(blackBeePay, 14)),
        actions: [
          TextButton(
            onPressed: () {
              // En Clean Architecture idealmente disparas un caso de uso desde un Bloc/Cubit:
              // context.read<PerfilBloc>().add(DeactivateAccountEvent());
              // De mientras, navega a una pantalla que gestione la acción:
              Navigator.pushNamed(context, '/desactivar');
            },
            child: Text('Desactivar', style: semibold(Colors.red, 14)),
          ),
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.amber.shade100),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: semibold(blackBeePay, 14)),
          ),
        ],
      ),
    );
  }
}

// ===================== Error =====================
class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
              child: Text(message, style: regular(Colors.red.shade800, 14))),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PerfilBloc>().add(GetPerfilEvent()),
          ),
        ],
      ),
    );
  }
}
