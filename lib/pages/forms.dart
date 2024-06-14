import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/api.dart'; // Remplacez par votre chemin d'import approprié
// Page de détails du formulaire, si nécessaire
import './DetailsFormulaire.dart';
import '../db.dart';

class ListFormulaires extends StatefulWidget {
  const ListFormulaires({Key? key}) : super(key: key);
  @override
  _ListFormulairesState createState() => _ListFormulairesState();
}

class _ListFormulairesState extends State<ListFormulaires> {
  List<Map<String, dynamic>> dataList = [];

  @override
  void initState() {
    super.initState();
    fetchFormulaires(); // Récupère les données au démarrage
  }

  Future<void> fetchFormulaires() async {
    List<Map<String, dynamic>> res =
        await db().select("SELECT * FROM formilair");
    int count = res.length;
    print("$count. forms has been inserted");
    if (count > 0) {
      print("$count. forms has been inserted");
      setState(() {
        dataList = res;
      });
    } else {
      // ******************************* *********get the data from the api and insert it in the local database*********************************************************************88

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
          setState(() {
            dataList = res;
          });
        } else {
          print('Error: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching data: $e');
      }

      // ******************************** ***************************************************************************************88
    }

    //  check if the questions are got form the api and gtting the if not
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
             print("${done} questions has been inserted sucssesfuly and ${failed} one failed");

          }
        } catch (e) {
          print('Error fetching data: $e');
        }
      }
     
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1.0, bottom: 30.0), // Adjust the padding as needed
          child: Text(
            'Enregistrements',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: dataList.isEmpty
              ? Center(child: CircularProgressIndicator()) // Loading indicator
              : ListView.builder(
                  itemCount: dataList.length,
                  itemBuilder: (context, index) {
                    var item = dataList[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FormulaireDetails(
                              idFormulaire: item['id'], // ID of the form
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          borderRadius: BorderRadius.circular(10), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.library_books,
                                    color: Color.fromARGB(255, 189, 189, 189)), // Icon on the left
                                SizedBox(width: 15), // Space between icon and text
                                Text(
                                  item['titre'] ?? "", // Name of the form
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios, color: Colors.grey), // Arrow on the right
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    ),
  );
}
}