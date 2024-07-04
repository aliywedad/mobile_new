import 'package:flutter/material.dart';
import 'package:mobile/pages/enregistrements.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/api.dart'; // Remplacez par votre chemin d'import approprié
// Page de détails du formulaire, si nécessaire
import './DetailsFormulaire.dart';
import '../db.dart';
import '../components/tost.dart';
import '../components/Alerts.dart';
 
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, String>> _profileData;

  @override
  void initState() {
    super.initState();
    _profileData = _loadProfileData();
  }
  
  Future<Map<String, String>> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? 'default@example.com';
    final nom = prefs.getString('nom') ?? 'DefaultNom';
    final prenom = prefs.getString('prenom') ?? 'DefaultPrenom';
    final tel = prefs.getString('tel') ?? '0000000000';
    final id = prefs.getInt('id') ?? 0;
    // print("id is ${id} ============================================================================================ ");
    return {
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'tel': tel,
    };
  }
  
@override
Widget build(BuildContext context) {
  return Scaffold(
// appBar: AppBar(
//           backgroundColor: Colors.white,
//           title: Padding(
//             padding: const EdgeInsets.only(left: 188.0, right: 16.0,top: 1.0,bottom: 40.0), // Ajustez les valeurs de marge selon vos besoins
//             child: Text(
//               'Compte Utilisateur',
//               style: TextStyle(
//                 color: Colors.black, // Couleur du texte
//                 fontSize: 20.0, 
//                 fontWeight: FontWeight.bold,// Taille de la police
//               ),
//             ),
//           ),
// ),
    backgroundColor: Colors.white,
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Color(0xFF364057),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<Map<String, String>>(
            future: _profileData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading profile data'));
              } else if (!snapshot.hasData) {
                return Center(child: Text('No profile data found'));
              } else {
                final data = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('images/male_profile.png'), // Corrected the path
                      ),
                    ),
                    SizedBox(height: 60),
                    ProfileField(
                      label: 'Email',
                      value: data['email']!,
                    ),
                    ProfileField(
                      label: 'Nom',
                      value: '${data['nom']} ${data['prenom']}',
                    ),
                    ProfileField(
                      label: 'Téléphone',
                      value: data['tel']!,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Enregistrements()),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20), // Space at the bottom of the card
                        padding: const EdgeInsets.all(20), // Inner space
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          borderRadius: BorderRadius.circular(10), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5), // Soft shadow
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3), // Shadow offset
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // To keep elements separated
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_city, color: Color.fromARGB(255, 189, 189, 189)), // Icon on the left
                                SizedBox(width: 10), // Space between icon and text
                                Text(
                                  "les enregistrements",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios, color: Colors.grey), // Arrow on the right
                          ],
                        ),
                      ),
                    ),
                   
                   


                    GestureDetector(
                      onTap: () async{
                        await synchron(context);

                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20), // Space at the bottom of the card
                        padding: const EdgeInsets.all(10), // Inner space
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          borderRadius: BorderRadius.circular(10), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5), // Soft shadow
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3), // Shadow offset
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // To keep elements separated
                          children: [
                            Row(
                              children: [
                                Icon(Icons.update, color: Color.fromARGB(255, 189, 189, 189)), // Icon on the left
                                SizedBox(width: 10), // Space between icon and text
                                Text(
                                  "Mettre à jour les données",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios, color: Colors.grey), // Arrow on the right
                          ],
                        ),
                      ),
                    ),
                   




                   
                    // SizedBox(height: 10),
                     // Space between the card and the button
                    // Center(
                    //   child: ElevatedButton(
                    //     onPressed: () async {
                    //       await synchron(context);
                    //     },
                    //     child: Text('Mettre à jour les données'),
                    //     style: ElevatedButton.styleFrom(
                    //       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15), // Adjust padding for the button
                    //       textStyle: TextStyle(fontSize: 16), // Adjust text style
                    //     ),
                    //   ),
                    // ),
                  
                  ],
                );
              }
            },
          ),
        ),
      ),
    ),
  );
}

}

Future<bool> synchron(BuildContext context) async {
  bool done = true;
  print(
      "*****************************synchronise the data { *********************************");

  // Supprimer toutes les données des tables
  await db().delete("DELETE FROM formilair");
  await db().delete("DELETE FROM typeinfrastructur");
  await db().delete("DELETE FROM infrastructur");
  await db().delete("DELETE FROM question");
  await db().delete("DELETE FROM wilaya");
  await db().delete("DELETE FROM moughata");
  await db().delete("DELETE FROM commune");
  await db().delete("DELETE FROM village");
  await db().delete("DELETE FROM user");

  // Insérer les nouvelles données à partir des API
  try {
    var url = Uri.parse(Api.forms); // Votre URL API
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      List<Map<String, dynamic>> data = jsonList.cast<Map<String, dynamic>>();
      int failed = 0;
      int done = 0;
      for (Map<String, dynamic> i in data) {
        int idform = i['id'];
        String formilair = i['formilair'] ?? '';
        String description = i['description'] ?? '';
        int response = await db().insrt(""" INSERT INTO 'formilair'
             (id, titre,description) 
            VALUES ( ${idform},'${formilair}','${description}'); """);
        if (response == 1) {
          done++;
        } else {
          failed++;
        }
      }
      print("${done} formilair has been inserted sucssesfuly and ${failed} one failed");
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching data: $e');
  }

  try {
    var url = Uri.parse(Api.typeInfra); // Votre URL API
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      List<Map<String, dynamic>> data = jsonList.cast<Map<String, dynamic>>();

      for (Map<String, dynamic> i in data) {
        int id = i['id'];
        String nom = i['nom'] ?? '';
        int response = await db().insrt(""" INSERT INTO 'typeinfrastructur'
             (id, nom) 
            VALUES ( ${id},'${nom}'); """);
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching data: $e');
  }

  try {
    var url = Uri.parse(Api.infra); // Votre URL API
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      List<Map<String, dynamic>> data = jsonList.cast<Map<String, dynamic>>();

      for (Map<String, dynamic> i in data) {
        int id = i['id'] ?? 0;
        String nom = i['nom'] ?? '';
        String description = i['description'] ?? '';
        int type = i['type'] ?? 0;
        int response = await db().insrt(""" INSERT INTO 'infrastructur'
             (id, nom,description,type) 
            VALUES ( ${id},'${nom}','${description}',${type}); """);
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching data: $e');
  }

  try {
    var response = await http.get(Uri.parse(Api.questions));
    if (response.statusCode == 200) {
      var jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      List<Map<String, dynamic>> data = jsonList.cast<Map<String, dynamic>>();
      int failed = 0;
      int done = 0;
      for (Map<String, dynamic> i in data) {
        int idQ = i['id'];
        String text = i['text'] ?? '';
        String choices = i['choices'] ?? '';
        String categorie = i['categorie'] ?? '';
        String type = i['type'] ?? '';
        int formilair = i['formilair'] ?? 0;
        int response = await db().insrt(""" INSERT INTO 'question'
                (id, formilair_id,text,type,choices,categorie) 
                VALUES ( ${idQ},'${formilair}',"${text}",'${type}',"${choices}",'${categorie}'); """);
        if (response == 1) {
          done++;
        } else {
          failed++;
        }
      }
      print(
          "${done} questions has been inserted sucssesfuly and ${failed} one failed");
    }
  } catch (e) {
    print('Error fetching data: $e');
  }

  try {
    var url = Uri.parse(Api.wilaya); // URL de votre API
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonList = jsonDecode(response.body);
      List<Map<String, dynamic>> data = jsonList.cast<Map<String, dynamic>>();
      for (Map<String, dynamic> i in data) {
        int code = i['ID_wilaya'];
        String nom = i['Nom_wilaya'];
        int response = await db().insrt(
            "INSERT INTO 'wilaya' (ID_wilaya, Nom_wilaya) VALUES (${code}, '${nom}');");
      }
    } else {
      print('Erreur: ${response.statusCode}');
    }
  } catch (e) {
    print('Erreur lors de la récupération des données: $e');
  }

  try {
    var url = Uri.parse(Api.moughataa);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      List<Map<String, dynamic>> data = jsonList.cast<Map<String, dynamic>>();
      int failed = 0;
      int done = 0;
      for (Map<String, dynamic> i in data) {
        int code = i['codeWilaye'];
        int idmohgataa = i['ID_maghataa'];
        String nom = i['nom'];
        print('$code , $nom');
        int response = await db().insrt(
            "INSERT INTO 'moughata' (ID_maghataa, Nom_maghataa,ID_wilaya) VALUES (${idmohgataa}, '${nom}',${code});");
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching data: $e');
  }

  try {
    var url = Uri.parse(Api.commin);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      List<Map<String, dynamic>> data = jsonList.cast<Map<String, dynamic>>();

      for (Map<String, dynamic> i in data) {
        int idcommun = i['ID_commin'];
        int idmohgataa = i['ID_maghataa'];
        String nom = i['nom'];
        int response = await db().insrt(
            "INSERT INTO 'commune' (ID_commune, Nom_commune,ID_maghataa_id) VALUES (${idcommun}, '${nom}',${idmohgataa});");
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching data: $e');
  }

  try {
    var url = Uri.parse(Api.village);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      List<Map<String, dynamic>> data = jsonList.cast<Map<String, dynamic>>();
      int failed = 0;
      int done = 0;
      for (Map<String, dynamic> i in data) {
        int idvillage = i['idvillage'];
        double DistanceAxesPrincipaux =
            i['DistanceAxesPrincipaux'].toDouble();
        double DistanceChefLieu = i['DistanceChefLieu'].toDouble();
        int IDCommin = i['idCommin'];
        String nomAdministratif = i['nomAdministratif'] ?? '';
        String NomLocal = i['NomLocal'] ?? '';
        String CompositionEthnique = i['CompositionEthnique'] ?? '';
        String DateCreation =
            i['DateCreation']; // Keep as String for SQLite

        int response = await db().insrt(""" INSERT INTO 'village'
             (NumeroVillage, idCommit,NomAdministratifVillage,NomLocal,DistanceChefLieu,DateCreation,DistanceAxesPrincipaux,CompositionEthnique,AutresInfosVillage) 
            VALUES (${idvillage},${IDCommin},"${nomAdministratif}","${NomLocal}",${DistanceChefLieu},${DateCreation} ,${DistanceAxesPrincipaux},'${CompositionEthnique}'," "); """);
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching data: $e');
  }

  try {
    var url = Uri.parse(Api.uesrs); // Votre URL API
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      List<Map<String, dynamic>> data = jsonList.cast<Map<String, dynamic>>();
      for (Map<String, dynamic> i in data) {
             int iduser = i['id'];
            int tel = i['tel'];
            String email = i['email'];
            String password = i['password'];
            String nom = i['nom'] ?? '';
            String prenom = i['prenom'] ?? '';
            String role = i['role'];
            int active = i['active'] ? 1 : 0;

            int response = await db().insrt(""" INSERT INTO 'user'
                 (id, tel,email,password,role,nom,prenom,active) 
                VALUES (${iduser},${tel},'${email}','${password}','${role}','${nom}' ,'${prenom}',${active}); """);
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching data: $e');
  }

  // Vérifier les données insérées
  int checkCount = 0;
  List<String> tables = [
    "wilaya",
    "moughata",
    "commune",
    "village",
    "formilair",
    "question",
    "typeinfrastructur",
    "infrastructur",
    "user"
  ];

  for (String table in tables) {
    var res = await db().select("SELECT * FROM $table");
    checkCount = res.length;
    print("${checkCount} $table has been inserter");
    if (checkCount == 0) {
      done = false;
    }
  }

  print("***************************** synchronise the data }*********************************");

  // Show dialog after synchronization
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Synchronization Complete'),
        content: Text(done ? 'Data synchronized successfully.' : 'Data synchronization failed.'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );

  return done;
}



class ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const ProfileField({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
