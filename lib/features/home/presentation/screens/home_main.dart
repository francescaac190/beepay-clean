import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/cores.dart';
import '../../data/datasources/home_service.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'tickets_screen.dart';
import 'transactions_screen.dart';
import 'profile_screen.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({Key? key}) : super(key: key);

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  int _selectedIndex = 0;

  late final HomeService _homeService;
  late Future<bool> _firstLoginFuture;

  final List<Widget> _screens = [
    HomeScreen(),
    CategoriesScreen(),
    TicketsScreen(),
    TransactionsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _homeService = HomeService(Dio());
    _initializeData(); // Llamamos a la función que maneja async
  }

  _initializeData() async {
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: background2,
        body: SafeArea(bottom: false, child: _screens[_selectedIndex]),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: amber,
          unselectedItemColor: gris7,
          currentIndex: _selectedIndex,
          selectedLabelStyle: regular(amber, 13),
          unselectedLabelStyle: regular(gris7, 12),
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category_rounded),
              label: 'Categorías',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number_rounded),
              label: 'Tickets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz_rounded),
              label: 'Historial',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
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
                "¡Es muy importante que recordés y guardés tu código operacional!\nTe permitirá validar y confirmar todas las transacciones dentro de la app.\nTe recomendamos anotarlo en papel y guardarlo en un lugar seguro.",
                style: regular(blackBeePay, 16),
              ),
              addVerticalSpace(10),
              Center(
                child: Text(
                  pin,
                  textAlign: TextAlign.center,
                  style: bold(blackBeePay, 24),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.amber.shade100),
            ),
            child: Text(
              "Siguiente",
              style: medium(amber, 15),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
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
            CustomTextFormField(razonController, TextInputType.name,
                TextCapitalization.words, false, 'Razón Social', (value) {
              if (value == null || value.isEmpty) {
                return "Ingrese un nombre válido";
              }
              return null;
            }, null),
            CustomTextFormField(nitController, TextInputType.number,
                TextCapitalization.none, false, 'NIT', (value) {
              if (value == null || value.isEmpty) {
                return "Ingrese un nit válido";
              }
              return null;
            }, null),
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
        content: Text(
            "Para usar Face ID / Touch ID activa esta opción en tu perfil."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cerrar", style: medium(amber, 15)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              print('navega a biometrica en perfil');
              // Navigator.pushNamed(context, '/biometria');
            },
            child: Text("Activar", style: medium(amber, 15)),
          ),
        ],
      ),
    );
  }
}
