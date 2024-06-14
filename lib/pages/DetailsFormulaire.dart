import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/api.dart';
import 'package:mobile/pages/Mis_a_joure.dart';
import 'package:mobile/pages/enregistrements.dart';
import './forms.dart';
import './infra.dart';
import '../db.dart';
import 'package:intl/intl.dart';
import '../components/tost.dart';
import './forms.dart';
import './village.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final int idvillage;

  // Provide default values for idFormulaire and idvillage
  const FormulaireDetails({
    Key? key,
    this.idFormulaire = 0, // Default value for idFormulaire
    this.idvillage = 0, // Default value for idvillage
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
  List<Map<String, dynamic>> lesWilaya = [];
  List<Map<String, dynamic>> lesMoghataa = [];
  List<Map<String, dynamic>> lesCommun = [];
  List<Map<String, dynamic>> lesVillgae = [];

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
    if (widget.idvillage > 0) {
      selectedVillage = widget.idvillage.toString();
      print("the selcted village is ${selectedVillage}");
    }
    fetchFormulaireDetails();
    fetchInfraDta();
    Get_DA_data();
    print("formilaire ${widget.idFormulaire} village ${widget.idvillage}");
  }

  Future<void> Get_DA_data() async {
    lesWilaya = await db().select("SELECT * FROM wilaya");
    lesMoghataa = await db().select("SELECT * FROM moughata");
    lesCommun = await db().select("SELECT * FROM commune");
    lesVillgae = await db().select("SELECT * FROM village");
    print(
        "******************************************************* ${lesWilaya.length}");
  }

  Future<void> fetchFormulaireDetails() async {
    List<Map<String, dynamic>> LesQuestions = await db().select(
        "SELECT * FROM question WHERE formilair_id=${widget.idFormulaire}");

    List<Map<String, dynamic>> myList = [
      {
        "formilair": "FICHE VILLAGE",
        "description": "description du formulaire",
        "questions": LesQuestions
      }
    ];
    setState(() {
      formulaireDetails = myList.isNotEmpty ? myList[0] : {};
      isLoading = false;
    });
  }

  Future<void> fetchInfraDta() async {
    List<Map<String, dynamic>> infra =
        await db().select("SELECT * FROM infrastructur  ");
    if (infra.isEmpty) {
      MisAjoure().synchron();
    }
    setState(() {
      dropdownItems = infra;
      print("nobre de l'infra est ${dropdownItems.length}");

      // List<Map<String, dynamic>>.from(json.decode(response.body));
    });
  }

  void addFields() {
    setState(() {
      // Générez un identifiant unique pour cet ensemble de champs
      final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();

      // Ajoutez un nouvel ensemble de champs texte à la liste de widgets
      fieldWidgets.add(
        Container(
          // padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 1),
          decoration: (BoxDecoration(
            color: Colors.blueGrey[50],
            border: Border.all(
              width: 1,
              color: Colors.black,
            ),
            borderRadius: BorderRadius.circular(0),
          )),
          child: Column(
            children: [
              // Ajoutez la liste déroulante avec la clé unique
              DropdownButtonFormField<String>(
                padding: const EdgeInsets.all(10),
                decoration: const InputDecoration(
                  labelText: 'infrastructur',
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
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  decoration: const InputDecoration(
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
              ),
              const SizedBox(
                  height:
                      20), // Ajouter un espace de 20 pixels entre chaque champ
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  decoration: const InputDecoration(
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
              ),
              SizedBox(height: 16)
            ],
          ),
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
                  color: Colors.black,
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
                  color: Colors.black,
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
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.black,
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Détails du Formulaire'),
        backgroundColor:Colors.white ,
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
                          color: Colors.black, // Couleur de la bordure
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
                          letterSpacing: 1.2,
                           // Espacement des lettres
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
                          color: Colors.black,
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

                    if (widget.idvillage == 0)
                      // Dropdown for Wilaya
                      DropdownButtonFormField<String>(
                        hint: Text('Sélectionnez une Wilaya'),
                        value: selectedWilaya,
                        onChanged: (value) async {
                          // Perform the async operation outside of setState
                          selectedWilaya = value;
                          print("The selected wilaya is $selectedWilaya");
                          List<
                              Map<String,
                                  dynamic>> fetchedMoghataa = await db().select(
                              "SELECT * FROM moughata WHERE ID_wilaya = $selectedWilaya");
                          print(fetchedMoghataa);

                          // Then update the state with the new data
                          setState(() {
                            lesMoghataa = fetchedMoghataa;
                            // Reset other selections as needed
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
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.black,
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
                      ),

                    if (widget.idvillage == 0) const SizedBox(height: 16),
                    if (widget.idvillage == 0)
                      // Dropdown for moghataa

                      DropdownButtonFormField<String>(
                        hint: Text('Sélectionnez une moughata'),
                        value: selectedMoughataa,
                        onChanged: (value) async {
                          selectedMoughataa = value;
                          List<
                              Map<String,
                                  dynamic>> fetchedCommun = await db().select(
                              "SELECT * FROM commune where ID_maghataa_id=${selectedMoughataa}");
                          print(
                              "the selected moughata is ${selectedMoughataa}");
                          setState(() {
                            lesCommun = fetchedCommun;
                          });
                        },
                        items: lesMoghataa.map((moghataa) {
                          return DropdownMenuItem(
                            value: moghataa['ID_maghataa'].toString(),
                            child: Text(moghataa['Nom_maghataa']),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'moghataa',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.black,
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
                      ),
                    if (widget.idvillage == 0) const SizedBox(height: 16),
                    if (widget.idvillage == 0)

                      // Dropdown for Communs

                      DropdownButtonFormField<String>(
                        hint: Text('Sélectionnez une commune'),
                        value: selectedCommune,
                        onChanged: (value) async {
                          selectedCommune = value;
                          List<
                              Map<String,
                                  dynamic>> fetchedCommun = await db().select(
                              "SELECT * FROM village where idCommit= ${selectedCommune}");
                          print("the selected moughata is ${selectedCommune}");
                          setState(() {
                            lesVillgae = fetchedCommun;

                            // Reset other selections as needed
                          });
                        },
                        items: lesCommun.map((moghataa) {
                          return DropdownMenuItem(
                            value: moghataa['ID_commune'].toString(),
                            child: Text(moghataa['Nom_commune']),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'commune',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.black,
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
                      ),
                    if (widget.idvillage == 0) const SizedBox(height: 16),
                    if (widget.idvillage == 0)

                      // Dropdown for villages

                      DropdownButtonFormField<String>(
                        hint: Text('Sélectionnez une village'),
                        value: selectedVillage,
                        onChanged: (value) {
                          selectedVillage = value;
                        },
                        items: lesVillgae.map((moghataa) {
                          return DropdownMenuItem(
                            value: moghataa['NumeroVillage'].toString(),
                            child: Text(moghataa['NomAdministratifVillage']),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'village',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.black,
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
                      ),

                    const SizedBox(height: 16),

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
                        color: Colors.white,
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
                        if (selectedVillage != null) {
                          print(" selected one is ${selectedVillage}");
                          sendData(); // Appel fictif à la fonction d'envoi
                        } else {
                          Tost().alert(
                              context,
                              "Vous devez choisir le village ! ",
                              Color.fromARGB(255, 245, 165, 55),
                              Icons.warning);
                        }
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
    final prefs = await SharedPreferences.getInstance();
    final iduser = prefs.getInt('id') ?? 0;
    int infra = 0;
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
    String date = formatter.format(now);
    int village_info = int.parse(selectedVillage ?? '0');
    if (iduser != 0) {
      try {
        fieldValues.forEach((key, value) async {
          if (key.startsWith('typeInfra_')) {
            var uniqueId = key.split('_')[1];
            int typeInfra = int.tryParse(value ?? '') ?? 0;
            ;
            int fonctionnelles =
                int.tryParse(fieldValues['fonctionnelles_$uniqueId'] ?? '') ??
                    0;
            int nonfonctionnelles = int.tryParse(
                    fieldValues['nonFonctionnelles_$uniqueId'] ?? '') ??
                0;
            int total = fonctionnelles + nonfonctionnelles;
            // print("village ${village.runtimeType} type ${typeInfra.runtimeType}  fonction ${fonctionnelles.runtimeType} nf ${nonfonctionnelles.runtimeType} t ${total.runtimeType} ");
            infra = await db().insrt(""" INSERT INTO infrastructuresvillage
          (NumeroVillage,id_user,TypeInfrastructure,NombreTotal,NombreFonctionnelles,NombreNonFonctionnelles,date_info,async)
          values ( ${village_info},${iduser},${typeInfra},${total},${fonctionnelles},${nonfonctionnelles},'${date}',0)
          """);
          }
          // print(" fieldValues  ${infra}");
        });
        List<Map<String, dynamic>> res = await db().select(
            "select * from infrastructuresvillage where NumeroVillage =${village_info}");
        print("${res.length} infrastructuresvillage has been inserted");

        formulaireDetails["questions"].forEach((question) async {
          var questionId = question["id"];
          var value = fieldValues[questionId.toString()] ?? '';

          infra = await db().insrt(""" INSERT INTO reponse
          (text_reponse,question_id,id_user,village ,response_date,async)
          values ( '${value}',${questionId},${iduser},${village_info} ,'${date}',0)
          """);
          print("${questionId} ${value}");
        });
        res = await db()
            .select("select * from reponse where village= ${village_info} ");
        print("${res.length} response has been inserted");

        Tost().alert(context, "the data has been inserted secsesfuly ! ",
            Colors.green, Icons.check);

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => Enregistrements()));
      } catch (e) {
        print('Erreur lors de l\'envoi des données : $e');
      }
    }
  }
}
