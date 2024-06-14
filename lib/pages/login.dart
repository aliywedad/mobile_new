import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/pages/Navbar.dart';
import 'package:mobile/pages/liste_DA.dart';
import 'Mis_a_joure.dart';
import '../db.dart';
import '../components/tost.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/Alerts.dart';

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

  late Future<bool> _dataLoadedFuture;

  @override
  void initState() {
    super.initState();
    _dataLoadedFuture = isDataLoaded();
  }

  Future<bool> isDataLoaded() async {
    bool dataLoaded = await MisAjoure().getusers();
    return dataLoaded;
  }

  void getLogin(String email, String password, BuildContext context) async {
    List res = await db().select("select * from user  ");
    print("\n \n \n ");

    print("${res.length} user ");

    print("\n \n \n ");
    if (res.length == 0) {
      await MisAjoure().getusers();
    }

    if (email == "" || password == "") {
      Tost().alert(
          context, "Remplissez tous les champs", Colors.red, Icons.warning);
    } else {
      List response =
          await db().select("select * from user where email='${email}'");
      if (response.length == 0) {
        Tost().alert(context, "Email incorrect", Colors.red, Icons.warning);
        // Alerts()
        //     .SimpleAlert(context, "Email incorrect","ok",  Colors.red, Icons.warning );
        await MisAjoure().getusers();
      } else if (response[0]['password'] == password) {
        String tel = response[0]['tel'].toString();
        SharedPreferences session = await SharedPreferences.getInstance();
        session.setString("email", email);
        session.setString("nom", response[0]['nom']);
        session.setString("prenom", response[0]['prenom']);
        session.setString("tel", tel);
        session.setInt("id", response[0]['id']);
        print(
            "${response[0]['id']} ${response[0]['email']} ${response[0]['nom']}  ${response[0]['prenom']} ${response[0]['tel']} PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP");
        // SharedPreferences }**********************************************

        MisAjoure().synchron();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavBar(),
          ),
        );
      } else {
        Tost()
            .alert(context, "Mot de pass incorrect", Colors.red, Icons.warning);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(24),
        child: FutureBuilder<bool>(
          future: _dataLoadedFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show CircularProgressIndicator while data is being loaded
              return Center(child: CircularProgressIndicator());
            } else {
              // Once data is loaded, show the login form
              return _buildLoginForm(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _header(),
        _inputField(context),
        _forgotPassword(),
        _signup(),
      ],
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
            // print("Email: $email");
            getLogin(email, password.toString(), context);
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
