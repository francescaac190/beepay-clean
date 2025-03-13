import 'dart:io';

import 'package:beepay/core/cores.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:beepay/injection_container.dart';
import '../bloc/register_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ciController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController verifyContrasenaController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RegisterBloc>(),
      child: Scaffold(
        backgroundColor: background2,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                BackMethodWidget(),
                FormRegister(
                  formKey: _formKey,
                  nombreController: nombreController,
                  apellidoController: apellidoController,
                  emailController: emailController,
                  phoneController: phoneController,
                  ciController: ciController,
                  codigoController: codigoController,
                  contrasenaController: contrasenaController,
                  verifyContrasenaController: verifyContrasenaController,
                ),
                addVerticalSpace(24),
                BlocConsumer<RegisterBloc, RegisterState>(
                  listener: (context, state) {
                    if (state is RegisterUserChecked) {
                      cerrarDialogoCargando(context);

                      Navigator.pushNamed(
                        context,
                        '/otp',
                        arguments: {
                          "name": nombreController.text,
                          "apellido": apellidoController.text,
                          "cel": phoneController.text,
                          "ci": ciController.text,
                          "email": emailController.text,
                          "password": contrasenaController.text,
                          "password_confirmation":
                              verifyContrasenaController.text,
                          "codigo": codigoController.text
                        },
                      );
                    } else if (state is RegisterLoading) {
                      dialogCargando(context, true);
                    } else if (state is RegisterError) {
                      cerrarDialogoCargando(context);

                      Mensaje(context, state.message);
                    }
                  },
                  builder: (context, state) {
                    return CustomButton(
                      text: "Registrarse",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (contrasenaController.text ==
                              verifyContrasenaController.text) {
                            BlocProvider.of<RegisterBloc>(context).add(
                              CheckUserEvent(
                                emailController.text,
                                phoneController.text,
                                ciController.text,
                                codigoController.text,
                              ),
                            );
                          } else {
                            MensajeError(
                                context, 'Las contraseñas no coinciden');
                          }
                        }
                      },
                      color: amber,
                      textColor: blanco,
                      width: double.infinity,
                      height: 50,
                    );
                  },
                ),
                addVerticalSpace(30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FormRegister extends StatefulWidget {
  const FormRegister({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.nombreController,
    required this.apellidoController,
    required this.emailController,
    required this.phoneController,
    required this.ciController,
    required this.codigoController,
    required this.contrasenaController,
    required this.verifyContrasenaController,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;
  final TextEditingController nombreController;
  final TextEditingController apellidoController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController ciController;
  final TextEditingController codigoController;
  final TextEditingController contrasenaController;
  final TextEditingController verifyContrasenaController;

  @override
  State<FormRegister> createState() => _FormRegisterState();
}

class _FormRegisterState extends State<FormRegister> {
  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget._formKey,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: blanco,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 7,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: [
            addVerticalSpace(16),
            Text('Formulario de Registro', style: semibold(blackBeePay, 20)),
            addVerticalSpace(16),

            //NOMBRE
            CustomTextFormField(
              widget.nombreController,
              TextInputType.text,
              TextCapitalization.words,
              false,
              'Nombre',
              (value) {
                if (value == null || value.isEmpty) {
                  return "Ingrese un nombre válido";
                }
                return null;
              },
              null,
            ),
            addVerticalSpace(12),
            //APELLIDO
            CustomTextFormField(
              widget.apellidoController,
              TextInputType.text,
              TextCapitalization.words,
              false,
              'Apellidos',
              (value) {
                if (value == null || value.isEmpty) {
                  return "Ingrese apellidos válidos";
                }
                return null;
              },
              null,
            ),
            addVerticalSpace(12),
            //NOMBRE
            CustomTextFormField(
              widget.emailController,
              TextInputType.emailAddress,
              TextCapitalization.none,
              false,
              'Email',
              (value) {
                if (value == null || value.isEmpty) {
                  return "Ingrese un email válido";
                }
                if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                    .hasMatch(value)) {
                  return 'Por favor ingresá un email valido';
                }

                return null;
              },
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: InkWell(
                  onTap: () {
                    showDataAlert(
                        "Email",
                        'El correo electrónico que ingreses debe ser único y válido. Ahí recibirás los códigos de confirmación.',
                        context);
                  },
                  child: Icon(
                    Icons.emergency_rounded,
                    color: rojo,
                    size: 15,
                  ),
                ),
              ),
            ),
            addVerticalSpace(12),
            //CI
            CustomTextFormField(
              widget.ciController,
              TextInputType.numberWithOptions(),
              TextCapitalization.none,
              false,
              'Número de documento',
              (value) {
                if (value == null || value.isEmpty) {
                  return "Ingrese un documento válido";
                }
                return null;
              },
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: InkWell(
                  onTap: () {
                    showDataAlert(
                        "Número de documento",
                        'El número de documento que ingreses debe ser único y válido. Más adelante deberás proporcionar imagenes de tu documento para validarlo.',
                        context);
                  },
                  child: Icon(
                    Icons.emergency_rounded,
                    color: rojo,
                    size: 15,
                  ),
                ),
              ),
            ),
            addVerticalSpace(12),
            //CELULAR
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  height: 60,
                  // width: 100,
                  child: CountryCodePicker(
                    // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                    initialSelection: '+591',
                    favorite: ['+591', 'BO'],
                    showCountryOnly: false,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                    headerText: 'Seleccionar país',
                    flagDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Expanded(
                  child: CustomTextFormField(
                    widget.phoneController,
                    TextInputType.phone,
                    TextCapitalization.words,
                    false,
                    'Número de celular',
                    (value) {
                      if (value == null || value.isEmpty) {
                        return "Ingrese un nombre válido";
                      }
                      return null;
                    },
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: InkWell(
                        onTap: () {
                          showDataAlert(
                              "Número de celular",
                              'El número de celular que ingreses debe ser único y válido, ya que con este ingresarás a tu cuenta de BeePay.',
                              context);
                        },
                        child: Icon(
                          Icons.emergency_rounded,
                          color: rojo,
                          size: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            addVerticalSpace(12),
            //CONTRASENA
            CustomTextFormField(
              widget.contrasenaController,
              TextInputType.text,
              TextCapitalization.none,
              _obscureText,
              'Contraseña',
              (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresá tu contraseña';
                }
                if (value.length < 8) {
                  return 'La contraseña debe tener al menos 8 caracteres';
                }

                return null;
              },
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                child: GestureDetector(
                  onTap: _toggle,
                  child: Icon(
                    _obscureText
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 24,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            addVerticalSpace(12),
            //CONFIRMAR CONTRASENA
            CustomTextFormField(
              widget.verifyContrasenaController,
              TextInputType.text,
              TextCapitalization.none,
              _obscureText,
              'Confirmar contraseña',
              (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresá tu contraseña';
                }
                if (value.length < 8) {
                  return 'La contraseña debe tener al menos 8 caracteres';
                }

                return null;
              },
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                child: GestureDetector(
                  onTap: _toggle,
                  child: Icon(
                    _obscureText
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 24,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            addVerticalSpace(12),
            //REFERIDOS
            CustomTextFormField(
              widget.codigoController,
              TextInputType.text,
              TextCapitalization.characters,
              false,
              'Referidos (Opcional)',
              (value) {
                return null;
              },
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: InkWell(
                  onTap: () {
                    showDataAlert(
                        "Código de referidos",
                        'Ingresá en este campo el código de referidos que es proporcionado por un usuario BeePay existente.',
                        context);
                  },
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: amber,
                  ),
                ),
              ),
            ),
            addVerticalSpace(16),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: regular(blackBeePay, 16),
                children: [
                  TextSpan(text: "Al registrarte aceptás los "),
                  TextSpan(
                    text: "Términos y Condiciones",
                    style: TextStyle(
                        color: amber,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PdfTermsCond()),
                        );
                      },
                  ),
                  TextSpan(text: " de BeePay"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PdfTermsCond extends StatefulWidget {
  const PdfTermsCond({super.key});

  @override
  State<PdfTermsCond> createState() => _PdfTermsCondState();
}

class _PdfTermsCondState extends State<PdfTermsCond> {
  String pathPDF = "";

  @override
  void initState() {
    super.initState();
    fromAsset('assets/Contrato Terminos y Condiciones de Uso (1).pdf',
            'Contrato Terminos y Condiciones de Uso (1).pdf')
        .then((f) {
      setState(() {
        pathPDF = f.path;
      });
    });
  }

  Future<File> fromAsset(String asset, String filename) async {
    try {
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");

      File assetFile = await file.writeAsBytes(bytes);
      return assetFile;
    } catch (e) {
      throw Exception("Error opening asset file");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
          bottom: false,
          child: Scaffold(
            appBar: AppBarWidget(),
            body: pathPDF.isNotEmpty
                ? PDFView(
                    filePath: pathPDF,
                  )
                : Center(child: LoadingWidget()),
          )),
    );
  }
}
