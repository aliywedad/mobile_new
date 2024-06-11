import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/api.dart'; // Remplacez par votre chemin d'import approprié
// Page de détails du formulaire, si nécessaire
import './DetailsFormulaire.dart';
import '../db.dart';
import '../components/tost.dart';
import '../components/Alerts.dart';

class MisAjoure {
  Future<List<Map<String, dynamic>>> selectAll(String table) async {
    // Example code to fetch data from the database using the db() function
    // Replace this with your actual database query
    return await db().select("SELECT * FROM {$table}");
  }

  static bool update = true;
  Future<bool> getusers() async {
    List<Map<String, dynamic>> res = await db().select("SELECT * FROM user");
    int count = res.length;

    if (count > 0) {
      print("$count. user has been inserted");
    } else {
      try {
        var url = Uri.parse(Api.uesrs);
        var response = await http.get(url);
        if (response.statusCode == 200) {
          var jsonList = jsonDecode(utf8.decode(response.bodyBytes));
          List<Map<String, dynamic>> data =
              jsonList.cast<Map<String, dynamic>>();
          print("********************************************************************************************status 200");
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
                  print("********************************************************************************************status code 400");

        }
      } catch (e) {
        print("********************************************************************************************status 400");
        print('Error fetching data: $e');
      }
    }

    res = await db().select("SELECT * FROM formilair");
    if (res.length > 0) {
      print("${res.length} has been inserted ");
      return true;
    } else {
      return false;
    }
  }

  Future<bool> synchron() async {
    bool done = true;
    print(
        "*****************************synchronise the data { *********************************");
    // got the forms from the api

    List<Map<String, dynamic>> res =
        await db().select("SELECT * FROM formilair");
    int count = res.length;
    if (count > 0) {
      print("$count. forms has been inserted");
    } else {
      try {
        var url = Uri.parse(Api.forms); // Votre URL API
        var response = await http.get(url);
        if (response.statusCode == 200) {
          var jsonList = jsonDecode(utf8.decode(response.bodyBytes));
          List<Map<String, dynamic>> data =
              jsonList.cast<Map<String, dynamic>>();
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
          print(
              "${done} formilair has been inserted sucssesfuly and ${failed} one failed");
          res = await db().select("SELECT * FROM formilair ");
        } else {
          print('Error: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching data: $e');
      }
    }

    res = await db().select("SELECT * FROM typeinfrastructur");
    count = res.length;
    if (count > 0) {
      print("$count. typeinfrastructur has been inserted");
    } else {
      try {
        var url = Uri.parse(Api.typeInfra); // Votre URL API
        var response = await http.get(url);
        if (response.statusCode == 200) {
          var jsonList = jsonDecode(utf8.decode(response.bodyBytes));
          List<Map<String, dynamic>> data =
              jsonList.cast<Map<String, dynamic>>();

          for (Map<String, dynamic> i in data) {
            int id = i['id'];
            String nom = i['nom'] ?? '';
            int response = await db().insrt(""" INSERT INTO 'typeinfrastructur'
                 (id, nom) 
                VALUES ( ${id},'${nom}'); """);
          }

          // res = await db().select("SELECT * FROM typeinfrastructur ");
        } else {
          print('Error: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching data: $e');
      }
    }

// got the ifrastructeur from the api

    res = await db().select("SELECT * FROM infrastructur");
    count = res.length;
    if (count > 0) {
      print("$count. infrastructur has been inserted");
    } else {
      try {
        var url = Uri.parse(Api.infra); // Votre URL API
        var response = await http.get(url);
        if (response.statusCode == 200) {
          var jsonList = jsonDecode(utf8.decode(response.bodyBytes));
          List<Map<String, dynamic>> data =
              jsonList.cast<Map<String, dynamic>>();

          for (Map<String, dynamic> i in data) {
            int id = i['id'] ?? 0;
            String nom = i['nom'] ?? '';
            String description = i['description'] ?? '';
            int type = i['type'] ?? 0;
            int response = await db().insrt(""" INSERT INTO 'infrastructur'
                 (id, nom,description,type) 
                VALUES ( ${id},'${nom}','${description}',${type}); """);
          }

          // res = await db().select("SELECT * FROM typeinfrastructur ");
        } else {
          print('Error: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching data: $e');
      }
    }

    // got the questions from the api
    List<Map<String, dynamic>> questions =
        await db().select("SELECT * FROM question");
    int questionsNumber = questions.length;
    print("$questionsNumber. question has been inserted");
    if (questionsNumber == 0) {
      try {
        var response = await http.get(Uri.parse(Api.questions));
        if (response.statusCode == 200) {
          var jsonList = jsonDecode(utf8.decode(response.bodyBytes));
          List<Map<String, dynamic>> data =
              jsonList.cast<Map<String, dynamic>>();
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
                    VALUES ( ${idQ},'${formilair}','${text}','${type}','${choices}','${categorie}'); """);
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
    }
    // got the wilaya from the api
    res = await db().select("SELECT * FROM wilaya");
    count = res.length;
    if (count > 0) {
      print("$count. wilaya has been inserted");
    } else {
      try {
        var url = Uri.parse(Api.wilaya); // URL de votre API
        var response = await http.get(url);
        if (response.statusCode == 200) {
          var jsonList = jsonDecode(response.body);
          List<Map<String, dynamic>> data =
              jsonList.cast<Map<String, dynamic>>();
          for (Map<String, dynamic> i in data) {
            int code = i['ID_wilaya'];
            String nom = i['Nom_wilaya'];
            // print('$code , $nom');
            int response = await db().insrt(
                "INSERT INTO 'wilaya' (ID_wilaya, Nom_wilaya) VALUES (${code}, '${nom}');");
          }
        } else {
          print('Erreur: ${response.statusCode}');
        }
      } catch (e) {
        print('Erreur lors de la récupération des données: $e');
      }
    }

    // got the moghataa from the api

    res = await db().select("SELECT * FROM moughata");
    count = res.length;
    if (count > 0) {
      print("$count. mohgataa has been inserted");
    } else {
      try {
        var url = Uri.parse(Api.moughataa);
        var response = await http.get(url);
        if (response.statusCode == 200) {
          var jsonList = jsonDecode(utf8.decode(response.bodyBytes));
          List<Map<String, dynamic>> data =
              jsonList.cast<Map<String, dynamic>>();
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
    }
    // got the communs from the api

    res = await db().select("SELECT * FROM commune");
    count = res.length;
    print("$count. commune has been inserted");
    if (count > 0) {
    } else {
      try {
        var url = Uri.parse(Api.commin);
        var response = await http.get(url);
        if (response.statusCode == 200) {
          var jsonList = jsonDecode(utf8.decode(response.bodyBytes));
          List<Map<String, dynamic>> data =
              jsonList.cast<Map<String, dynamic>>();

          for (Map<String, dynamic> i in data) {
            int idcommun = i['ID_commin'];
            int idmohgataa = i['ID_maghataa'];
            String nom = i['nom'];
            // print('$code , $nom');
            int response = await db().insrt(
                "INSERT INTO 'commune' (ID_commune, Nom_commune,ID_maghataa_id) VALUES (${idcommun}, '${nom}',${idmohgataa});");
          }
        } else {
          print('Error: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching data: $e');
      }
    }

    // got the villages from the api

    res = await db().select("SELECT * FROM village");
    count = res.length;

    if (count > 0) {
      print("$count. village has been inserted");
    } else {
      try {
        var url = Uri.parse(Api.village);
        var response = await http.get(url);
        if (response.statusCode == 200) {
          var jsonList = jsonDecode(utf8.decode(response.bodyBytes));
          List<Map<String, dynamic>> data =
              jsonList.cast<Map<String, dynamic>>();
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
                VALUES (${idvillage},${IDCommin},'${nomAdministratif}','${NomLocal}',${DistanceChefLieu},${DateCreation} ,${DistanceAxesPrincipaux},'${CompositionEthnique}'," "); """);
          }
        } else {
          print('Error: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching data: $e');
      }
    }

    // got the users from the api

    res = await db().select("SELECT * FROM user");
    count = res.length;

    if (count > 0) {
      print("$count. user has been inserted");
    } else {
      try {
        var url = Uri.parse(Api.uesrs);
        var response = await http.get(url);
        if (response.statusCode == 200) {
          var jsonList = jsonDecode(utf8.decode(response.bodyBytes));
          List<Map<String, dynamic>> data =
              jsonList.cast<Map<String, dynamic>>();

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
    }

    res = await db().select("SELECT * FROM wilaya");
    if (res.length == 0) {
      done = false;
    }
    print("${res.length} wilaya has been inserter  ");
    res = await db().select("SELECT * FROM moughata");
    if (res.length == 0) {
      done = false;
    }
    print("${res.length} moughata has been inserter  ");
    res = await db().select("SELECT * FROM commune");
    if (res.length == 0) {
      done = false;
    }
    print("${res.length} commune has been inserter  ");
    res = await db().select("SELECT * FROM village");
    if (res.length == 0) {
      done = false;
    }
    print("${res.length} village has been inserter  ");
    res = await db().select("SELECT * FROM formilair");
    if (res.length == 0) {
      done = false;
    }
    print("${res.length} formilair has been inserter  ");
    res = await db().select("SELECT * FROM question");
    if (res.length == 0) {
      done = false;
    }
    print("${res.length} question has been inserter  ");
    res = await db().select("SELECT * FROM typeinfrastructur");
    if (res.length == 0) {
      done = false;
    }

    print("${res.length} typeinfrastructur has been inserter  ");
    res = await db().select("SELECT * FROM infrastructur");
    if (res.length == 0) {
      done = false;
    }

    print("${res.length} infrastructur has been inserter  ");
    res = await db().select("SELECT * FROM user");
    if (res.length == 0) {
      done = false;
    }
    print("${res.length} user has been inserter  ");
    print(
        "***************************** synchronise the data }*********************************");
    return done;
  }

  void telecharjerLesDonnerDuVillage(BuildContext context, idvillage) async {
    try {
      var url = Uri.parse(Api.connexion);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        print("connexion !!!!!!!!!!!!!!!!!!!! id village ${idvillage}");

        // getting the village infos

        int delet = await db()
            .delete("DELETE FROM reponse_online where village=${idvillage}");
        try {
          final response = await http.post(
            Uri.parse(Api.updateVillageInfo),
            body: jsonEncode({"id": idvillage}),
            headers: {'Content-Type': 'application/json'},
          );

          if (response.statusCode == 200) {
            var jsonList = jsonDecode(utf8.decode(response.bodyBytes));
            List<Map<String, dynamic>> data =
                jsonList.cast<Map<String, dynamic>>();
            for (Map<String, dynamic> i in data) {
              int id = i['id'];
              String text_reponse = i['text_reponse'] ?? '';
              String response_date = i['response_date'] ?? '';
              int question_id = i['question_id'] ?? 0;
              int village = i['village'] ?? 0;
              int id_user = i['id_user'] ?? 0;

              int response = await db().insrt(""" INSERT INTO 'reponse_online'
                      (id, text_reponse,response_date,question_id,village,id_user) 
                      VALUES ( ${id},'${text_reponse}','${response_date}',${question_id},${village},${id_user}); """);
            }
            List<Map<String, dynamic>> res = await db().select(
                "SELECT * FROM reponse_online where village=${idvillage} ");
            Tost().alert(
                context,
                "Les données ont été téléchargées correctement",
                Colors.green,
                Icons.check);

            int count = res.length;
            print(
                "${count} reponse_online online added for the village ${idvillage} ");
          } else if (response.statusCode == 202) {
            Tost().alert(
                context,
                "Il n'y a pas de données disponibles pour ce village",
                Color.fromARGB(255, 243, 160, 70),
                Icons.warning);
          }
        } catch (e) {
          print("Erreur: $e");
        }
        // getting the village infrastructeur village

        delet = await db().delete(
            "DELETE FROM infrastructuresvillage_Online where NumeroVillage=${idvillage}");
        try {
          final response = await http.post(
            Uri.parse(Api.InfraVillage),
            body: jsonEncode({"id": idvillage}),
            headers: {'Content-Type': 'application/json'},
          );

          if (response.statusCode == 200) {
            var jsonList = jsonDecode(utf8.decode(response.bodyBytes));
            List<Map<String, dynamic>> data =
                jsonList.cast<Map<String, dynamic>>();
            for (Map<String, dynamic> i in data) {
              int ID_Infrastructures = i['ID_Infrastructures'];
              int NombreTotal = i['NombreTotal'] ?? 0;
              int NombreNonFonctionnelles = i['NombreNonFonctionnelles'] ?? 0;
              int NombreFonctionnelles = i['NombreFonctionnelles'] ?? 0;
              String date_info = i['date_info'] ?? '';
              int NumeroVillage = i['NumeroVillage'] ?? 0;
              int TypeInfrastructure =
                  int.tryParse(i['TypeInfrastructure'] ?? '') ?? 0;
              // print(date_info);
              // print(NumeroVillage);
              int user = i['user'] ?? 0;
              int response = await db()
                  .insrt(""" INSERT INTO 'infrastructuresvillage_Online'
                      (ID_Infrastructures, NumeroVillage,user,TypeInfrastructure,NombreTotal,NombreFonctionnelles,NombreNonFonctionnelles,date_info) 
                      VALUES ( ${ID_Infrastructures},${NumeroVillage},${user},${TypeInfrastructure},${NombreTotal},${NombreNonFonctionnelles},${NombreFonctionnelles} ,'${date_info}'); """);
            }
            List<Map<String, dynamic>> res = await db().select(
                "SELECT * FROM infrastructuresvillage_Online where NumeroVillage=${idvillage}");
            print("${res.length} infrastructuresvillage_Online are inserted ");
            Tost().alert(
                context,
                "Les données ont été téléchargées correctement",
                Colors.green,
                Icons.check);

            int count = res.length;
            print(
                "${count} reponse_online online added for the village ${idvillage} ");
            print("the data is ${res}");
          } else if (response.statusCode == 202) {
            Tost().alert(
                context,
                "Il n'y a pas de données sure l'infrastructeur disponibles pour ce village",
                Color.fromARGB(255, 243, 160, 70),
                Icons.warning);
          }
        } catch (e) {
          print("Erreur: $e");
        }
      }
      //   Tost().alert(
      // context,
      // "Pas de connexion Internet. Veuillez vérifier votre connexion.",
      // Colors.red,
      // Icons.warning);
    } catch (e) {
      print('Error fetching data: $e');
    }
  }
}
