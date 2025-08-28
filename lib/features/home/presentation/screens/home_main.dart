import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cores.dart';
import '../../../perfil/presentation/screens/perfil_screen.dart';
import '../../data/datasources/home_service.dart';

// 👉 BLoC Perfil + wiring mínimo
import '../../domain/usecases/perfil_usecase.dart';
import '../../domain/repositories/home_repository.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../data/datasources/home_remote_datasources.dart';
import '../bloc/perfil_bloc.dart';

import 'home_screen.dart';
import 'categories_screen.dart';
import 'tickets_screen.dart';
import 'transactions_screen.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({Key? key}) : super(key: key);

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  int _selectedIndex = 0;

  late final Dio _dio; // una sola instancia
  late final HomeService _homeService;
  late Future<bool> _firstLoginFuture;

  // Dependencias para Perfil
  late final HomeRemoteDataSource _remoteDS;
  late final HomeRepository _homeRepo;
  late final GetCompletoUseCase _getCompletoUseCase;

  @override
  void initState() {
    super.initState();
    _dio = Dio();
    _homeService = HomeService(_dio);

    // wiring mínimo para el perfil
    _remoteDS = HomeRemoteDataSourceImpl(dio: _dio);
    _homeRepo = HomeRepositoryImpl(remoteDataSource: _remoteDS);
    _getCompletoUseCase = GetCompletoUseCase(_homeRepo);

    _initializeData();
  }

  Future<void> _initializeData() async {
    _firstLoginFuture = _homeService.firstLogin();
    _firstLoginFuture.then((isFirstLogin) async {
      if (isFirstLogin == true) {
        log("bool: ${isFirstLogin.toString()}");
        log('si es primer login');

        final String pin = await _homeService.getPinBeePay();
        if (pin.isNotEmpty) {
          await _showPinDialog(pin);
        }
        await _showRazonSocialDialog();
        await _showBiometricDialog();
      } else {
        log("bool: ${isFirstLogin.toString()}");
        log('no es primer login');
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // 👉 Envolvemos SOLO el tab Inicio con el BlocProvider y disparamos el evento
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return BlocProvider(
          create: (_) => PerfilBloc(_getCompletoUseCase)..add(GetPerfilEvent()),
          child: HomeScreen(),
        );
      case 1:
        return const CategoriesScreen();
      case 2:
        return const TicketsScreen();
      case 3:
        return const TransactionsScreen();
      case 4:
        return const PerfilScaffold();
      default:
        return BlocProvider(
          create: (_) => PerfilBloc(_getCompletoUseCase)..add(GetPerfilEvent()),
          child: HomeScreen(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        // backgroundColor: background2,
        body: SafeArea(bottom: false, child: _buildBody()),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: amber,
          unselectedItemColor: gris7,
          currentIndex: _selectedIndex,
          selectedLabelStyle: regular(amber, 13),
          unselectedLabelStyle: regular(gris7, 12),
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: 'Inicio'),
            BottomNavigationBarItem(
                icon: Icon(Icons.category_rounded), label: 'Categorías'),
            BottomNavigationBarItem(
                icon: Icon(Icons.confirmation_number_rounded),
                label: 'Tickets'),
            BottomNavigationBarItem(
                icon: Icon(Icons.swap_horiz_rounded), label: 'Historial'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: 'Perfil'),
          ],
        ),
      ),
    );
  }

  Future<void> _showPinDialog(String pin) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Pin BeePay", style: semibold(blackBeePay, 17)),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                "¡Es muy importante que recordés y guardés tu código operacional!\n"
                "Te permitirá validar y confirmar todas las transacciones dentro de la app.\n"
                "Te recomendamos anotarlo en papel y guardarlo en un lugar seguro.",
                style: regular(blackBeePay, 16),
              ),
              addVerticalSpace(10),
              Center(
                  child: Text(pin,
                      textAlign: TextAlign.center,
                      style: bold(blackBeePay, 24))),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStatePropertyAll(Colors.amber.shade100)),
            child: Text("Siguiente", style: medium(amber, 15)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showRazonSocialDialog() async {
    final TextEditingController nitController = TextEditingController();
    final TextEditingController razonController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Facturación", style: semibold(blackBeePay, 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Guardá tus datos para facturación",
                style: regular(blackBeePay, 15)),
            CustomTextFormField(
              razonController,
              TextInputType.name,
              TextCapitalization.words,
              false,
              'Razón Social',
              (value) => (value == null || value.isEmpty)
                  ? "Ingrese un nombre válido"
                  : null,
              null,
            ),
            CustomTextFormField(
              nitController,
              TextInputType.number,
              TextCapitalization.none,
              false,
              'NIT',
              (value) => (value == null || value.isEmpty)
                  ? "Ingrese un nit válido"
                  : null,
              null,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: medium(amber, 15))),
          TextButton(
            onPressed: () {
              _homeService.postAgregarFactura(
                  nitController.text, razonController.text);
              Navigator.pop(context);
              razonController.clear();
              nitController.clear();
            },
            child: Text("Guardar", style: medium(amber, 15)),
          ),
        ],
      ),
    );
  }

  Future<void> _showBiometricDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Activación Biometría", style: semibold(blackBeePay, 17)),
        content: const Text(
            "Para usar Face ID / Touch ID activa esta opción en tu perfil."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cerrar", style: medium(amber, 15))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigator.pushNamed(context, '/biometria');
            },
            child: Text("Activar", style: medium(amber, 15)),
          ),
        ],
      ),
    );
  }
}
