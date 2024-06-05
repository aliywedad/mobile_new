import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/pages/Navbar.dart';
import 'package:mobile/pages/liste_DA.dart';
import 'Mis_a_joure.dart';
import '../db.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    synchron();
  }

  Future<void> synchron() async {
    MisAjoure().synchron();
  }

  void getLogin(String email, String password, BuildContext context) async {
    // List response =
    //     await db().select("select * from user where email='${email}'");
    // if (0 == 0) {
    //   if (password == 1234) {
    //     print("login");
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => BottomNavBar(),
    //       ),
    //     );
    //   } else {
      //   print("password incorrect");
      //   Fluttertoast.showToast(
      //     msg: "mot de pass incorrect",
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: const Color.fromARGB(255, 240, 116, 107),
      //     textColor: Colors.white,
      //     fontSize: 16.0,
      //   );
             Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavBar(),
          ),
        );
      }
    // } else {
    //   print(response[0]['password']);
    //   Fluttertoast.showToast(
    //     msg: "email incorrect",
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.CENTER,
    //     timeInSecForIosWeb: 1,
    //     backgroundColor: const Color.fromARGB(255, 240, 116, 107),
    //     textColor: Colors.white,
    //     fontSize: 16.0,
    //   );
    // }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _header(),
            _inputField(context),
            _forgotPassword(),
            _signup(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return const Column(
      children: [
        Text(
          "Bienvenue",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text("Entrez vos identifiants pour vous connecter"),
      ],
    );
  }

  Widget _inputField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: usernameController,
          decoration: InputDecoration(
            hintText: "Email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.blueGrey[50],
            filled: true,
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            hintText: "Mot de passe",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.blueGrey[50],
            filled: true,
            prefixIcon: const Icon(Icons.lock),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            final email = usernameController.text;
            final password = passwordController.text;
            print("Email: $email");
            getLogin(email, password, context);
          },
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.blueGrey[50],
          ),
          child: const Text(
            "Login",
            style: TextStyle(fontSize: 20),
          ),
        )
      ],
    );
  }

  Widget _forgotPassword() {
    return TextButton(
      onPressed: () {},
      child: const Text(
        "Mot de passe oublié ?",
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _signup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Vous n'avez pas de compte ?"),
        TextButton(
          onPressed: () {},
          child: const Text(
            "S'inscrire",
            style: TextStyle(color: Colors.purple),
          ),
        )
      ],
    );
  }
}
