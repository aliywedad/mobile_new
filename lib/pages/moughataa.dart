import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../API.dart';
import './commin.dart';
import '../db.dart';

class Moughataa extends StatefulWidget {
  final int idWilaya;
  final String nomWilaya;

  const Moughataa({
    Key? key,
    required this.idWilaya,
    required this.nomWilaya,
  }) : super(key: key);

  @override
  State<Moughataa> createState() => _MoughataaState();
}

class _MoughataaState extends State<Moughataa> {
  List<Map<String, dynamic>> dataList = [];
  List<Map<String, dynamic>> filteredList = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    List<Map<String, dynamic>> res =
        await db().select("SELECT * FROM moughata");
    int count = res.length;
    print("$count. mohgataa has been inserted");

    if (count > 0) {
      print("$count. mohgataa has been inserted");
      setState(() {
        if (widget.idWilaya > 0) {
          dataList = res
              .cast<Map<String, dynamic>>()
              .where((item) => item["ID_wilaya"] == widget.idWilaya)
              .toList();
              filteredList = dataList;
        } else {
          dataList = res.cast<Map<String, dynamic>>();
          filteredList = dataList;

        }
      });
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
            if (response == 1) {
              done++;
            } else {
              failed++;
            }
          }
          print(
              "${done} has been inserted sucssesfuly and ${failed} one failed");
          setState(() {
            if (widget.idWilaya > 0) {
              dataList = jsonList
                  .cast<Map<String, dynamic>>()
                  .where((item) => item["ID_wilaya"] == widget.idWilaya)
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
        title: widget.nomWilaya.isNotEmpty
            ? Text(
                'Les Moughataa du ${widget.nomWilaya}',
                style: TextStyle(fontSize: 18),
              )
            : 
            Text(
                'Les Moughataa  ',
                style: TextStyle(fontSize: 18),
              ),
        backgroundColor: Colors.white,
      ),
      
      body: Column(
        children: [
                            Container(
  padding: const EdgeInsets.all(16.0),
  child: TextField(
    onChanged: (value) {
                    setState(() {
                      filteredList = dataList
                          .where((item) => item['Nom_maghataa']
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
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                var item = filteredList[index];
                var nomMoughataa = item["Nom_maghataa"] ?? 'Nom inconnu';
            
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                            nomMoughataa,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Commin(
                                idMoughataa: item["ID_maghataa"],
                                nomMouhgataa: nomMoughataa,
                              ),
                            ),
                          );
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
