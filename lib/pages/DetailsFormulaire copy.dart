// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/api.dart';
import 'package:mobile/db.dart';
import './forms.dart';
import './infra.dart';

// Fonction pour obtenir des données depuis un point de terminaison
Future<List<Map<String, dynamic>>> fetchData(String apiUrl) async {
  final response = await http.get(Uri.parse(apiUrl));
  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  } else {
    throw Exception("Erreur lors du chargement des données");
  }
}

class FormulaireDetails extends StatefulWidget {
  final int idFormulaire;

  const FormulaireDetails({
    Key? key,
    required this.idFormulaire,
  }) : super(key: key);

  @override
  _FormulaireDetailsState createState() => _FormulaireDetailsState();
}

class _FormulaireDetailsState extends State<FormulaireDetails> {
  Map<String, dynamic> formulaireDetails = {};
  bool isLoading = true;

  String? selectedWilaya;
  String? selectedMoughataa;
  String? selectedCommune;
  String? selectedVillage;
  List<Widget> fieldWidgets = [];
  List<Widget> typeInfra = [];
  List<Widget> InfraNonFonc = [];
  List<Widget> InfraFonc = [];
  List<Map<String, dynamic>> dropdownItems = [];
  TextEditingController numberController1 = TextEditingController();
  TextEditingController numberController2 = TextEditingController();
  Color borderColor = Color.fromRGBO(255, 0, 0, 1.0);
  @override
  void initState() {
    super.initState();
    fetchFormulaireDetails();
    fetchInfraDta();
  }

  Future<void> fetchFormulaireDetails() async {

    try {
      final response = await http.post(
        Uri.parse(Api.getforms),
        body: jsonEncode({"id": widget.idFormulaire}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          formulaireDetails = data.isNotEmpty ? data[0] : {};
          isLoading = false;
        });
      } else {
        throw Exception(
            "Erreur lors de la récupération des détails du formulaire");
      }
    } catch (e) {
      print("Erreur: $e");
    }
  }
  List<Map<String, dynamic>> lesWilaya =   db().select("SELECT * FROM wilaya");

  Future<void> fetchInfraDta() async {
    final response = await http.get(Uri.parse(Api.infra));
    if (response.statusCode == 200) {
      setState(() {
        dropdownItems =
            List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      throw Exception("Erreur lors du chargement des données");
    }
  }

  void addFields() {
    setState(() {
      // Générez un identifiant unique pour cet ensemble de champs
      final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();

      // Ajoutez un nouvel ensemble de champs texte à la liste de widgets
      fieldWidgets.add(
        Column(
          children: [
            // Ajoutez la liste déroulante avec la clé unique
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
              onChanged: (String? value) {
                setState(() {
                  fieldValues["typeInfra_$uniqueId"] = value;
                });
                print(
                    "Nouvelle sélection pour la question {typeInfra_$uniqueId: $value }");
              },
              onSaved: (value) {
                fieldValues["typeInfra_$uniqueId"] = value;
              },
            ),
            SizedBox(
                height:
                    20), // Ajouter un espace de 20 pixels entre chaque champ
            // Ajoutez les champs texte avec les clés uniques

            TextFormField(
              decoration: InputDecoration(
                labelText: 'nonFonctionnelles',
              ),
              keyboardType: TextInputType.number,
              onChanged: (String? value) {
                setState(() {
                  fieldValues['nonFonctionnelles_$uniqueId'] = value;
                });
                print(
                    "Nouvelle sélection pour la question {nonFonctionnelles_$uniqueId: $value}");
              },
              onSaved: (value) {
                fieldValues['nonFonctionnelles_$uniqueId'] = value;
              },
            ),
            SizedBox(
                height:
                    20), // Ajouter un espace de 20 pixels entre chaque champ
            TextFormField(
              decoration: InputDecoration(
                labelText: 'fonctionnelles',
              ),
              keyboardType: TextInputType.number,
              onChanged: (String? value) {
                setState(() {
                  fieldValues['fonctionnelles_$uniqueId'] = value;
                });
                print(
                    "Nouvelle sélection pour la question {fonctionnelles_$uniqueId: $value}");
              },
              onSaved: (value) {
                fieldValues['fonctionnelles_$uniqueId'] = value;
              },
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

  Map<String, dynamic> fieldValues = {};
  Widget buildQuestionWidget(Map<String, dynamic> question) {
    String questionType = question["type"];

    // Définir la couleur de la bordure
    final Color borderColor = Colors.blue;

    Widget buildFormField() {
      switch (questionType) {
        case "text":
          return TextFormField(
            decoration: InputDecoration(
              labelText: question["text"],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.blueAccent,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (String? value) {
              setState(() {
                fieldValues[question["id"].toString()] = value;
              });
              print(
                  "Nouvelle sélection pour la question ${question["id"]}: $value");
            },
            onSaved: (value) {
              fieldValues[question["id"].toString()] = value;
            },
          );

        case "number":
          return TextFormField(
            decoration: InputDecoration(
              labelText: question["text"],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.blueAccent,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.number,
            onChanged: (String? value) {
              setState(() {
                fieldValues[question["id"].toString()] = value;
              });
              print(
                  "Nouvelle sélection pour la question ${question["id"]}: $value");
            },
            onSaved: (value) {
              fieldValues[question["id"].toString()] = value;
            },
          );

        case "choices":
          var choicesData = question["choices"];
          List<String> choices = [];

          if (choicesData is String && choicesData.isNotEmpty) {
            var dataWithoutBrackets =
                choicesData.substring(2, choicesData.length - 2);
            var elements = dataWithoutBrackets.split("', '");
            choices.addAll(elements);
          } else {
            print("choicesData n'est pas une chaîne de caractères valide");
          }

          return Form(
            key: GlobalKey<FormState>(),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: question['text'],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.blueAccent,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.blueAccent,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.blueAccent,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              dropdownColor: Colors.white,
              items: choices.map((choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  fieldValues[question["id"].toString()] = value;
                });
                print(
                    "Nouvelle sélection pour la question ${question["id"]}: $value");
              },
              onSaved: (value) {
                fieldValues[question["id"].toString()] = value;
              },
            ),
          );

        default:
          return Text('Type de question inconnu');
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: buildFormField(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du Formulaire'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Autres détails du formulaire et questions
                    Container(
                      width: 400.0,
                      padding: EdgeInsets.all(
                          16.0), // Ajoute de l'espace autour du texte
                      decoration: BoxDecoration(
                        color: Colors.white, // Couleur de fond
                        border: Border.all(
                          color: Colors.blueAccent, // Couleur de la bordure
                          width: 2.0, // Épaisseur de la bordure
                        ),
                        borderRadius:
                            BorderRadius.circular(8.0), // Coins arrondis
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey
                                .withOpacity(0.5), // Couleur de l'ombre
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3), // Décalage de l'ombre
                          ),
                        ],
                      ),
                      child: Text(
                        'Titre du Formulaire : ${formulaireDetails["formilair"] ?? "Inconnu"}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Couleur du texte
                          letterSpacing: 1.2, // Espacement des lettres
                        ),
                      ),
                    ),

                    SizedBox(height: 10),
                    Container(
                      width: double.infinity, // Largeur maximale disponible
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.blueAccent,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        'Description : ${formulaireDetails["description"] ?? "Aucune description"}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                    // Liste déroulante pour wilaya
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchData(Api.wilaya),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Erreur lors du chargement des wilayas');
                        } else {
                          return DropdownButtonFormField<String>(
                            hint: Text('Sélectionnez une Wilaya'),
                            value: selectedWilaya,
                            onChanged: (value) {
                              setState(() {
                                selectedWilaya = value;
                                selectedMoughataa = null;
                                selectedCommune = null;
                                selectedVillage = null;
                                // Charger les moughataas pour la wilaya sélectionnée
                              });
                            },
                            items: lesWilaya.map((wilaya) {
                              return DropdownMenuItem(
                                value: wilaya['ID_wilaya'].toString(),
                                child: Text(wilaya['Nom_wilaya']),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: 'Wilaya',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                            ),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            dropdownColor: Colors.white,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Liste déroulante pour moughataa
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchData(Api.moughataa),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text(
                              'Erreur lors du chargement des moughataas');
                        } else {
                          var filteredMoughataas = selectedWilaya == null
                              ? []
                              : snapshot.data!.where((m) {
                                  var codeWilaye = m['codeWilaye'];
                                  print(codeWilaye.runtimeType);
                                  return codeWilaye != null &&
                                      codeWilaye.toString() == selectedWilaya;
                                }).toList();

                          return DropdownButtonFormField<String>(
                            hint: Text('Sélectionnez un Moughataa'),
                            value: selectedMoughataa,
                            onChanged: selectedWilaya == null
                                ? null
                                : (value) {
                                    setState(() {
                                      selectedMoughataa = value;
                                      selectedCommune = null;
                                      selectedVillage = null;
                                      // Charger les communes pour le moughataa sélectionné
                                    });
                                  },
                            items: filteredMoughataas.map((moughataa) {
                              return DropdownMenuItem(
                                value: moughataa['ID_maghataa'].toString(),
                                child: Text(moughataa['nom']),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: 'Moughataa',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                            ),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            dropdownColor: Colors.white,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Liste déroulante pour commune
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchData(Api.commin),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Erreur lors du chargement des communes');
                        } else {
                          var filteredCommunes = selectedMoughataa == null
                              ? []
                              : snapshot.data!.where((c) {
                                  var codem = c['ID_maghataa'];
                                  return codem != null &&
                                      codem.toString() == selectedMoughataa;
                                }).toList();

                          return DropdownButtonFormField<String>(
                            hint: Text('Sélectionnez une Commune'),
                            value: selectedCommune,
                            onChanged: selectedMoughataa == null
                                ? null
                                : (value) {
                                    setState(() {
                                      selectedCommune = value;
                                      selectedVillage = null;
                                      // Charger les villages pour la commune sélectionnée
                                    });
                                  },
                            items: filteredCommunes.map((commune) {
                              return DropdownMenuItem(
                                value: commune['ID_commin'].toString(),
                                child: Text(commune['nom']),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: 'Commune',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                            ),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            dropdownColor: Colors.white,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Liste déroulante pour village
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchData(Api.village),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Erreur lors du chargement des villages');
                        } else {
                          var filteredVillages = selectedCommune == null
                              ? []
                              : snapshot.data!.where((v) {
                                  var codev = v['idCommin'];
                                  return codev != null &&
                                      codev.toString() == selectedCommune;
                                }).toList();
                          return DropdownButtonFormField<String>(
                            hint: Text('Sélectionnez un Village'),
                            value: selectedVillage,
                            onChanged: selectedCommune == null
                                ? null
                                : (value) {
                                    setState(() {
                                      selectedVillage = value;
                                      // Logique supplémentaire après sélection
                                    });
                                  },
                            items: filteredVillages.map((village) {
                              return DropdownMenuItem(
                                value: village['idvillage'].toString(),
                                child: Text(village['nomAdministratif']),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: 'Village',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                            ),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            dropdownColor: Colors.white,
                          );
                        }
                      },
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: formulaireDetails["questions"]?.length ?? 0,
                      itemBuilder: (context, index) {
                        var question = formulaireDetails["questions"][index];
                        return buildQuestionWidget(question);
                      },
                    ),
                    SingleChildScrollView(
                      child: Card(
                        elevation:
                            4, // L'élévation donne un effet d'ombre à la carte
                        margin:
                            EdgeInsets.all(10), // Espacement autour de la carte
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...fieldWidgets, // Affichez tous les widgets de champs stockés dans la liste
                              const SizedBox(
                                  height:
                                      16), // Espacement entre les champs et les boutons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed:
                                        addFields, // Utilisez la fonction addFields pour ajouter de nouveaux champs
                                    child: Text('Ajouter'),
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        removeFields, // Utilisez la fonction removeFields pour supprimer les champs
                                    child: Text('Supprimer'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        sendData(); // Appel fictif à la fonction d'envoi
                      },
                      child: Text('Envoyer'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> sendData() async {
    try {
      List<Map<String, dynamic>> questions = [];
      List<Map<String, dynamic>> infrastructures = [];

      formulaireDetails["questions"].forEach((question) {
        var questionId = question["id"];
        var value = fieldValues[questionId.toString()] ?? '';

        questions.add({
          "id": questionId,
          "value": value,
        });
      });

      fieldValues.forEach((key, value) {
        if (key.startsWith('typeInfra_')) {
          var uniqueId = key.split('_')[1];
          var typeInfra = value;
          var fonctionnelles =
              int.tryParse(fieldValues['fonctionnelles_$uniqueId'] ?? '') ?? 0;
          var nonfonctionnelles =
              int.tryParse(fieldValues['nonFonctionnelles_$uniqueId'] ?? '') ??
                  0;
          var total = fonctionnelles + nonfonctionnelles;
          print(selectedVillage);
          infrastructures.add({
            "typeInfra": typeInfra,
            "fonctionnelles": fonctionnelles,
            "nonFonctionnelles":
                nonfonctionnelles, // Utilisez 'nonFonctionnelles' au lieu de 'nonfonctionnelles'
            "total": total,
          });
        }
      });

      var dataToSend = {
        "village": selectedVillage,
        "dataList": questions,
        "infrastructures": infrastructures,
      };

      var url = Uri.parse(Api.inserer_donnees);
      var response = await http.post(
        url,
        body: jsonEncode(dataToSend),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Données envoyées avec succès');
      } else {
        print('Erreur lors de l\'envoi des données : ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de l\'envoi des données : $e');
    }
  }
}
