import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/api.dart';
import './moughataa.dart';
import 'Navbar.dart';
import '../db.dart';

void main() {
  runApp(Wilaya());
}

class Wilaya extends StatefulWidget {
  const Wilaya({Key? key}) : super(key: key);

  @override
  State<Wilaya> createState() => _WilayaState();
}

class _WilayaState extends State<Wilaya> {
  List<Map<String, dynamic>> dataList = [];
  List<Map<String, dynamic>> filteredList = [];
  int _tapCount = 0; // Pour gérer les double-taps

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    List<Map<String, dynamic>> res = await db().select("SELECT * FROM wilaya");
    int count = res.length;
    if (count > 0) {
      print("$count wilaya(s) have been inserted");
      setState(() {
        dataList = res;
        filteredList = res; // Initialize filtered list with all data
      });
    } else {
      print("No wilaya has been inserted");
      try {
        var url = Uri.parse(Api.wilaya); // URL of your API
        var response = await http.get(url);
        if (response.statusCode == 200) {
          var jsonList = jsonDecode(response.body);
          List<Map<String, dynamic>> data =
              jsonList.cast<Map<String, dynamic>>();
          for (Map<String, dynamic> i in data) {
            int code = i['ID_wilaya'];
            String nom = i['Nom_wilaya'];
            await db().insrt(
                "INSERT INTO 'wilaya' (ID_wilaya, Nom_wilaya) VALUES ($code, '$nom');");
          }
          List<Map<String, dynamic>> newdata =
              await db().select("SELECT * FROM wilaya");
          setState(() {
            dataList = newdata;
            filteredList = newdata; // Initialize filtered list with all data
          });
          print("The data fetched from the API has been inserted into the DB");
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
       title:Text(
          'Wilayas',
                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
  padding: const EdgeInsets.all(16.0),
  child: TextField(
    onChanged: (value) {
            setState(() {
              filteredList = dataList.where((item) =>
                  item['Nom_wilaya']
                      .toLowerCase()
                      .contains(value.toLowerCase())).toList();
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

                return Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 15), // Margin around the card
                  padding: const EdgeInsets.all(20), // Inner padding
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Soft shadow
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    // Horizontal alignment
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        // Align icon and text
                        children: [
                          const Icon(Icons.location_city,
                              color: Color.fromARGB(
                                  255, 189, 189, 189)), // Icon on the left
                          const SizedBox(width: 10), // Space between icon and text
                          Text(
                            item['Nom_wilaya'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Moughataa(
                                idWilaya: item["ID_wilaya"],
                                nomWilaya: item["Nom_wilaya"],
                              ),
                            ),
                          );
                        },
                        child: const Icon(Icons.arrow_forward_ios,
                            color: Color(0xFF364057)), // Arrow on the right
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
