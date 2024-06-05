import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/pages/profile.dart';
import './wilaya.dart';
import './moughataa.dart';
import './commin.dart';
import './village.dart';
import './liste_DA.dart';
import './forms.dart';
import './login.dart';

void main() {
  runApp(BottomNavBar());
}

class BottomNavBar extends StatefulWidget {
  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  int selected = 0;
  DateTime? lastPressed;

  List<Widget> listwidget = [
    const Liste_DA(),
    const ListFormulaires(),
    const ProfilePage( ),
  ];

  List<String> listtitels = [
    "Division administrative",
    "Formulaires",
    "Profil",
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: WillPopScope(
          onWillPop: () async {
            DateTime now = DateTime.now();
            if (lastPressed == null ||
                now.difference(lastPressed!) > Duration(seconds: 2)) {
              lastPressed = now;
              Fluttertoast.showToast(
                msg: "Appuyez deux fois pour quitter",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              return false; // Prevent the default behavior
            }
            return true; // Allow the default behavior (exit the app)
          },
          child: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              selectedItemColor:   Colors.white,
              type: BottomNavigationBarType.fixed,
              currentIndex: selected,
              unselectedItemColor: Colors.black,
              backgroundColor: Color(0xFF364057),
              onTap: (val) {
                setState(() {
                  selected = val;
                });
              },
              selectedFontSize: 15,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.location_city), label: "DA"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.library_books), label: "Enregistrements"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: "Profil"),
              ],
            ),
            appBar: AppBar(
              // title: Text((listtitels.elementAt(selected))),
              title: Text(" "),
              backgroundColor: Colors.white,
              centerTitle: true,
            ),
            body: listwidget.elementAt(selected),
          ),
        ),
      ),
    );
  }
}
