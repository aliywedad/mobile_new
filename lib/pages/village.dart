import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/pages/DetailsFormulaire.dart';
import 'package:mobile/pages/visualiser.dart';
import 'package:mobile/pages/visualiserInfrastructeur.dart';
import '../API.dart';
import '../db.dart';
import './Mis_a_joure.dart';
import '../components/tost.dart';

class village extends StatefulWidget {
  final int diCommit;
  final String nomCommin; // Added Wilaya Name

  const village({
    Key? key,
    required this.diCommit,
    required this.nomCommin,
  }) : super(key: key);

  @override
  State<village> createState() => _villageState();
}

class _villageState extends State<village> {
  List<Map<String, dynamic>> dataList = [];
  List<Map<String, dynamic>> filteredList = [];

  @override
  void initState() {
    super.initState();
    getdata();
  }

  Future<void> getdata() async {
    // int delet = await db().delete("delete  FROM village");
    List<Map<String, dynamic>> res = await db()
            .select("SELECT village.*,commune.Nom_commune FROM village,commune where  commune.ID_commune=village.idCommit");
    int count = res.length;

    if (count > 0) {
      print("$count. village has been inserted");
      if (widget.diCommit > 0) {
        res = await db()
            .select("SELECT village.*,commune.Nom_commune FROM village,commune where village.idCommit =${widget.diCommit} and commune.ID_commune=village.idCommit");
      }
      setState(() {
        dataList = res;
        filteredList = dataList;
      });
    } else {
      print("loading the data ............................");

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
            if (response == 1) {
              done++;
            } else {
              failed++;
            }
          }
          print(
              "${done} village has been inserted sucssesfuly and ${failed} one failed");

          if (widget.diCommit > 0) {
            res = await db().select(
                "SELECT * FROM village where idCommit =${widget.diCommit}");
          } else {
            res = await db().select("SELECT * FROM village ");
          }
          setState(() {
            dataList = res;
            filteredList = dataList;
          });
        } else {
          print('Error: ${response.statusCode}');
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
      appBar: 
AppBar(
        title: widget.nomCommin.isNotEmpty
            ? Text(
                'Les villages du ${widget.nomCommin}',
                style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
              )
            : 
            Text(
                'Les villages  ',
                style: TextStyle(fontSize: 18),
              ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
 
      body:
       Column(
         children: [
                  Container(
  padding: const EdgeInsets.all(16.0),
  child: TextField(
    onChanged: (value) {
                  setState(() {
                    filteredList = dataList
                        .where((item) => item['NomAdministratifVillage']
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                  });
    },
    decoration: InputDecoration(
      labelText: 'Rechercher',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.blueGrey, width: 2.0),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      filled: true,
      fillColor: Colors.blueGrey[50],
      prefixIcon: Icon(Icons.search, color: Color(0xFF364057)),
    ),
    style: TextStyle(
      color: Color(0xFF364057),
      fontSize: 16,
    ),
  ),
),

           Expanded(
             child: ListView.separated(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                var item = filteredList[index];
                return ListTile(
                  title: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 15, horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Align children at the ends of the row
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nom du village: ${item["NomAdministratifVillage"]} \n nom local : ${item["NomLocal"]} ',
                            ),
                            Text('Date du Creation : ${item["DateCreation"]} '),
                            Text("commune : ${item['Nom_commune']}")
                          ],
                        ),
PopupMenuButton(
  color: Color(0xFF364057),
  onSelected: (val) async {
    if (val == "inserer") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FormulaireDetails(
            idvillage: item["NumeroVillage"],
            idFormulaire: 55,
          ),
        ),
      );
    }
    if (val == "visialuser") {
      List<Map<String, dynamic>> result = await db().select(
          "SELECT reponse_online.response_date, user.nom, user.prenom FROM reponse_online, user WHERE village=${item["NumeroVillage"]} AND reponse_online.question_id in (select id from question where formilair_id =55)  and user.id=reponse_online.id_user GROUP BY response_date");
      if (result.isEmpty) {
        Tost().alert(context, "Il n'y a pas de données disponibles pour ce village. Réessayez de télécharger les données.", Color.fromARGB(255, 243, 160, 70), Icons.warning);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Visualiser(
              idVillage: item["NumeroVillage"],
              idFormulaire: 55,
            ),
          ),
        );
      }
    }
    if (val == "telecharger") {
      MisAjoure().telecharjerLesDonnerDuVillage(context, item["NumeroVillage"]);
    }
  },
  itemBuilder: (context) => [
    const PopupMenuItem(
      value: "inserer",
      child: Text(
        "inserer des donner",
        style: TextStyle(color: Colors.white),
      ),
    ),
    const PopupMenuItem(
      value: "visialuser",
      child: Text(
        "visialuser les donner du village",
        style: TextStyle(color: Colors.white),
      ),
    ),
    const PopupMenuItem(
      value: "telecharger",
      child: Text(
        "telecharger le donner du cett village",
        style: TextStyle(color: Colors.white),
      ),
    ),
  ],
),

                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => Divider(
                color: Colors.white,
              ),
                   ),
           ),
         ],
       ),
    );
  }
}