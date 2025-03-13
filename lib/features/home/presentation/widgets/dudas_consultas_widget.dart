import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/cores.dart';

class DudasConsultasWidget extends StatelessWidget {
  const DudasConsultasWidget({Key? key}) : super(key: key);

  _launchURL(String phoneNumber, String message) async {
    var url = "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('no se puede');
      await Fluttertoast.showToast(
        msg: 'WhatsApp no está instalado en tu dispositivo.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Obtain the store URL based on the platform
      String storeUrl = '';
      if (Platform.isAndroid) {
        storeUrl = 'https://play.google.com/store/apps/details?id=com.whatsapp';
      } else if (Platform.isIOS) {
        storeUrl =
            'https://apps.apple.com/us/app/whatsapp-messenger/id310633997';
      }

      // Open the store URL for downloading WhatsApp
      await launch(storeUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 23, vertical: 15),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/JUST-BEE-PRODUCTOS-ok-02 1.png',
            height: 170,
          ),
          addVerticalSpace(8),
          ElevatedButton(
            onPressed: () {
              _launchURL("59178192170", "Hola tengo dudas sobre BeePay");

              // BlocProvider.of<ContactSupportBloc>(context).add(
              //   OpenWhatsAppEvent(
              //     ContactSupportEntity(
              //       phoneNumber: "59178192170",
              //       message: "Hola tengo dudas sobre BeePay",
              //     ),
              //   ),
              // );
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: amber,
              foregroundColor: blanco,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              minimumSize: const Size(double.infinity, 45),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.help, color: blanco),
                  addHorizontalSpace(8),
                  Text(
                    'Contactanos',
                    style: semibold(blanco, 21),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
