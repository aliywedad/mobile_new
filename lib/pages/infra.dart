import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/api.dart';

class CustomFormWidget extends StatefulWidget {
  @override
  _CustomFormWidgetState createState() => _CustomFormWidgetState();
}
class _CustomFormWidgetState extends State<CustomFormWidget> {
  TextEditingController numberController1 = TextEditingController();
  TextEditingController numberController2 = TextEditingController();
  List<Map<String, dynamic>> dropdownItems = [];
  List<Widget> fieldWidgets = []; // Liste pour stocker les widgets de champs

  @override
  void initState() {
    super.initState();
    fetchData(Api.infra);
  }

  Future<void> fetchData(String apiUrl) async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        dropdownItems = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      throw Exception("Erreur lors du chargement des données");
    }
  }

 void addFields() {
  setState(() {
    // Ajoutez un nouvel ensemble de champs texte à la liste de widgets
    fieldWidgets.add(
      Column(
        children: [
          // Ajoutez la liste déroulante
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Dropdown Field',
            ),
            items: dropdownItems.map((item) {
              return DropdownMenuItem<String>(
                value: item['id'].toString(),
                child: Text(item['nom']),
              );
            }).toList(),
            onChanged: (value) {
              // Do something with the selected value
            },
          ),
          // Ajoutez les champs texte
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Numeric Field 1',
            ),
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Numeric Field 2',
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  });
}
void removeFields() {
  setState(() {
    // Vérifiez d'abord s'il y a des champs à supprimer
    if (fieldWidgets.isNotEmpty) {
      // Supprimez le dernier ensemble de champs de la liste
      fieldWidgets.removeLast();
    }
  });
}
Map<String, dynamic> getFormValues() {
  // Récupérer les valeurs des champs texte
  String numericFieldValue1 = numberController1.text;
  String numericFieldValue2 = numberController2.text;

  // Récupérer la valeur sélectionnée dans la liste déroulante
  String selectedDropdownValue = dropdownItems.isNotEmpty
      ? dropdownItems[0]['id'].toString() // Supposons que vous récupériez la valeur du premier élément de la liste
      : '';

  // Créer un objet contenant les valeurs récupérées
  Map<String, dynamic> formValues = {
    'numericFieldValue1': numericFieldValue1,
    'numericFieldValue2': numericFieldValue2,
    'selectedDropdownValue': selectedDropdownValue,
  };

  return formValues;
}




  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...fieldWidgets, // Affichez tous les widgets de champs stockés dans la listex
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: addFields, // Utilisez la fonction addFields pour ajouter de nouveaux champs
              child: Text('Ajouter'),
            ),
          ElevatedButton(
              onPressed: removeFields, // Utilisez la fonction removeFields pour supprimer les champs
              child: Text('Supprimer'),
            ),
          ],
        ),
      ],
    );
  }
}
