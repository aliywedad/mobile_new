import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/pages/village.dart';
import '../API.dart';
import '../db.dart';
import '../components/tost.dart';

class Commin extends StatefulWidget {
  final int idMoughataa;
  final String nomMouhgataa;

  const Commin({
    Key? key,
    required this.idMoughataa,
    required this.nomMouhgataa,
  }) : super(key: key);

  @override
  State<Commin> createState() => _ComminState();
}

class _ComminState extends State<Commin> {
  List<Map<String, dynamic>> dataList = [];
  List<Map<String, dynamic>> filteredList = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    List<Map<String, dynamic>> res = await db().select("SELECT * FROM commune");
    int count = res.length;
    print("$count. mohgataa has been inserted");

    if (count > 0) {
      print("$count. commune has been inserted");
      setState(() {
        if (widget.idMoughataa > 0) {
          dataList = res
              .cast<Map<String, dynamic>>()
              .where((item) => item["ID_maghataa_id"] == widget.idMoughataa)
              .toList();
          filteredList = dataList;
        }
        else{
          dataList= res;
          filteredList = dataList;
        }
      });
    } else {
      try {
        var url = Uri.parse(Api.commin);
        var response = await http.get(url);
        if (response.statusCode == 200) {
          var jsonList = jsonDecode(utf8.decode(response.bodyBytes));
          List<Map<String, dynamic>> data =
              jsonList.cast<Map<String, dynamic>>();
          int failed = 0;
          int done = 0;
          for (Map<String, dynamic> i in data) {
            int idcommun = i['ID_commin'];
            int idmohgataa = i['ID_maghataa'];
            String nom = i['nom'];
            // print('$code , $nom');
            int response = await db().insrt(
                "INSERT INTO 'commune' (ID_commune, Nom_commune,ID_maghataa_id) VALUES (${idcommun}, '${nom}',${idmohgataa});");
            if (response == 1) {
              done++;
            } else {
              failed++;
            }
          }
          print("${done} has been inserted sucssesfuly and ${failed} one failed");
          setState(() {
            if (widget.idMoughataa > 0) {
              dataList = jsonList
                  .cast<Map<String, dynamic>>()
                  .where((item) => item["ID_maghataa_id"] == widget.idMoughataa)
                  .toList();
              filteredList = dataList;
            } else {
              dataList = jsonList.cast<Map<String, dynamic>>();
              filteredList = dataList;
            }
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: widget.nomMouhgataa.isNotEmpty
            ? Text(
                'Les communes du ${widget.nomMouhgataa}',
                style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
              )
            : 
            Text(
                'Les communes ',
                style: TextStyle(fontSize: 18),
              ),
              centerTitle: true,
      ),
      body: 
      Column(
        children: [
                            Container(
  padding: const EdgeInsets.all(16.0),
  child: TextField(
    onChanged: (value) {
            if (value != " ") {
              setState(() {
                filteredList = dataList
                    .where((item) => item['Nom_commune']
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                    .toList();
              });
            }
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
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                var item = filteredList[index];
                var nomCommin = item["Nom_commune"] ?? 'Nom inconnu';
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: BorderRadius.circular(10),
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
                          Icon(Icons.location_city,
                              color: Color.fromARGB(255, 189, 189, 189)),
                          SizedBox(width: 10),
                          Text(
                            nomCommin,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
            
                          if (item["ID_commune"] != null) {
                              List<Map<String, dynamic>> result = await db().select("SELECT * from village where idCommit =${item["ID_commune"]} ");
                              if(result.length==0){
                                Tost().alert(context, "Il n'y a pas de villages disponibles pour  ${nomCommin} . Veuillez sélectionner une autre commune.", Color.fromARGB(255, 243, 160, 70), Icons.warning);
                              } 
                              else{
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => village(
                                      diCommit: item["ID_commune"],
                                      nomCommin: nomCommin,
                                    ),
                                  ),
                                );
                              }
            
                          }
                        },
                        child: Icon(Icons.arrow_forward_ios, color:Color(0xFF364057)),
                      ),
                    ],
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
