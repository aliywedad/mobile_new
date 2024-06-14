import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/pages/village.dart';
import '../API.dart';
import './wilaya.dart';
import './moughataa.dart';
import './commin.dart';
import 'village.dart';
import './Mis_a_joure.dart';
import 'package:mobile/api.dart';

class Liste_DA extends StatefulWidget {
  const Liste_DA({Key? key}) : super(key: key);
  @override
  State<Liste_DA> createState() => _Liste_DAState();
}

class _Liste_DAState extends State<Liste_DA> {
  int _tapCount = 0; // Variable to count taps, initialized to 0

  // Method to fetch data when the screen loads
  @override
  void initState() {
    super.initState();
  }

 

  // Function to navigate to different pages based on element name
  void _navigateToPage(String elementName) {
    if (elementName == "Wilaya") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Wilaya()),
      );
    } else if (elementName == "Moughataa") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Moughataa(idWilaya: 0, nomWilaya: "")),
      );
    } else if (elementName == "Commune") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Commin(idMoughataa: 0, nomMouhgataa: "")),
      );
    } else if (elementName == "Village") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => village(diCommit: 0, nomCommin: "")),
      );
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
            'Division administrative',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildElementCard("Wilaya"),
              _buildElementCard("Moughataa"),
              _buildElementCard("Commune"),
              _buildElementCard("Village"),
            ],
          ),
        ),
      ],
    ),
  );
}



  // Function to build each element card
  Widget _buildElementCard(String elementName) {
    return GestureDetector(
      onTap: () {
        _navigateToPage(elementName); // Action when tapping the card
      },
      child: 
      Container(
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
        child: Row(
          // To horizontally align
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // To keep elements separated
          children: [
            Row(
              children: [
                Icon(Icons.location_city,
                    color: Color.fromARGB(255, 189, 189, 189)), // Icon on the left
                SizedBox(width: 10), // Space between icon and text
                Text(
                  elementName,
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios,
                color: Color(0xFF364057)), // Arrow on the right
          ],
        ),
      ),
    
    );
  }
}
