import 'package:flutter/material.dart';
import '../db.dart'; // Adjust this import according to your actual db file location
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile/api.dart'; // Adjust this import according to your actual api file location
import '../components/tost.dart';

class Enregistrements extends StatefulWidget {
  final int idVillage;
  final int idFormulaire;

  const Enregistrements({Key? key, this.idVillage = 0, this.idFormulaire = 55})
      : super(key: key);

  @override
  State<Enregistrements> createState() => _VisualiserState();
}

class _VisualiserState extends State<Enregistrements> {
  List<Map<String, dynamic>> dateList = [];
  List<Map<String, dynamic>> infraList = [];
  String? valueUpdate;
  Map<String, List<Map<String, dynamic>>> responseDetails = {};
  String? expandedDate;

  @override
  void initState() {
    super.initState();
    fetchDateList();
  }

  Future<void> fetchDateList() async {
    // print("hhhhah from fetchDateList");

    try {
      List<Map<String, dynamic>> res = await db().select(
          "SELECT reponse.response_date, reponse.async, village.NomAdministratifVillage, user.nom, user.prenom FROM reponse, village, user WHERE village.NumeroVillage=reponse.village and reponse.question_id in (select id from question where formilair_id = ${widget.idFormulaire}) and user.id=reponse.id_user GROUP BY response_date");
      setState(() {
        dateList = res;
        print("Data updated with ${dateList.length} entries");
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> Upload(String date) async {
    print("Uploading data for date: $date");
    try {
      List<Map<String, dynamic>> res = await db()
          .select("SELECT * FROM reponse WHERE response_date = '$date'");
      List<Map<String, dynamic>> infrasiruct = await db().select(
          "SELECT * FROM infrastructuresvillage WHERE date_info = '$date'");
      final response = await http.post(
        Uri.parse(Api.Upload_Reponses),
        body: jsonEncode({"data": res, "infralist": infrasiruct}),
        headers: {'Content-Type': 'application/json'},
      );
      print(response.body);
      if (response.statusCode == 200) {
        print("Data uploaded successfully");
        int rep = await db().updat(
            "UPDATE reponse SET async = 1 WHERE response_date = '$date'");
        if (rep > 0) {
          fetchDateList();
        }
      } else {
        print("Failed to upload data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error uploading data: $e");
    }
  }

  Future<void> fetchResponseDetails(String responseDate) async {
    // print("hhhhah from fetchResponseDetails()  ${responseDate}");
    try {
      // if (!responseDetails.containsKey(responseDate)) {
      List<Map<String, dynamic>> res = await db().select(
          "SELECT reponse.*  , question.text FROM reponse, question WHERE reponse.question_id in (select id from question where formilair_id = ${widget.idFormulaire}) and question.id=reponse.question_id and reponse.response_date='$responseDate'");
      setState(() {
        // print("hhhhah from setState fetchResponseDetails() ${responseDate}");

        responseDetails[responseDate] = res;
        print(res);
      });
      // }
    } catch (e) {
      print("Error fetching response details: $e");
    }
  }

  Future<void> fetchInfraList(responseDate) async {
    try {
      List<Map<String, dynamic>> ifra = await db().select(
          "SELECT infrastructuresvillage.*, infrastructur.nom FROM infrastructuresvillage,infrastructur where infrastructur.id=infrastructuresvillage.TypeInfrastructure and  date_info ='${responseDate}'");
      setState(() {
        infraList = ifra;
      });
    } catch (e) {
      print("Error fetching infrastructure list: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visualiser'),
        backgroundColor: Colors.blueGrey[50],
      ),
      backgroundColor: Colors.white,
      body: dateList.isEmpty
          ? Center(child: Text("il n ya pas des enregistrement !"))
          : ListView.separated(
              itemCount: dateList.length,
              itemBuilder: (context, index) {
                var item = dateList[index];
                String responseDate = item['response_date'];
                bool isExpanded = expandedDate == responseDate;

                return ListTile(
                  title: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: item['async'] == 1
                          ? Colors.green[100]
                          : Colors.red[100],
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${responseDate.replaceAll('T', ' ').replaceAll('Z', '')}\nCollecté par ${item['nom']} ${item['prenom']}\npour le village ${item['NomAdministratifVillage']}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.start,
                              ),
                            ),
                            item['async'] == 1
                                ? Icon(Icons.check)
                                : IconButton(
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          actions: [
                                            Row(
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Fermer la boîte de dialogue
                                                  },
                                                  child: Text(
                                                      "Annuler"), // Texte corrigé en français
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    Upload(
                                                        item['response_date']);
                                                    Navigator.of(context)
                                                        .pop(); // Fermer la boîte de dialogue après l'envoi
                                                  },
                                                  child: Text(
                                                      "Envoyer"), // Texte corrigé en français
                                                ),
                                              ],
                                            ),
                                          ],
                                          title: const Icon(
                                            Icons.question_mark,
                                            color: Colors.red,
                                          ),
                                          content: const Text(
                                              "Voulez-vous vraiment envoyer les données au serveur ?"),
                                          contentPadding:
                                              const EdgeInsets.all(20.0),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.cloud_upload,
                                      color: Colors.green,
                                    ),
                                  ),
                            IconButton(
                              onPressed: () async {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          actions: [
                                            Row(
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                  },
                                                  child: Text(
                                                      "Annuler"), // Translated "cancel" to French
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    int delet_reponses =
                                                        await db().delete(
                                                            "DELETE FROM reponse WHERE response_date = '${responseDate}'");
                                                    int infras = await db().delete(
                                                        "DELETE FROM infrastructuresvillage WHERE date_info = '${responseDate}'");
                                                    if (delet_reponses > 0 ||
                                                        infras > 0) {
                                                      Tost().alert(
                                                          context,
                                                          "Les données ont été supprimées correctement",
                                                          Colors.green,
                                                          Icons.check);
                                                      fetchDateList();
                                                    }
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog after deletion
                                                  },
                                                  child: Text(
                                                      "Supprimer"), // Translated "delete" to French
                                                )
                                              ],
                                            )
                                          ],
                                          title: const Icon(
                                            Icons.warning_amber,
                                            color: Colors.red,
                                          ),
                                          content: const Text(
                                              "\n Voulez-vous vraiment supprimer cet enregistrement ?"),
                                          contentPadding:
                                              const EdgeInsets.all(20.0),
                                        ));
                              },
                              icon: Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                              ),
                            )
                          ],
                        ),
                        ExpansionTile(
                          title: Text("Détails"),
                          trailing: Icon(
                            isExpanded
                                ? Icons.arrow_drop_down_circle
                                : Icons.arrow_drop_down,
                          ),
                          children: [
                            responseDetails[responseDate] != null
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount:
                                        responseDetails[responseDate]?.length ??
                                            0,
                                    itemBuilder: (context, index) {
                                      var detailItem =
                                          responseDetails[responseDate]?[index];
                                      return ListTile(
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                "${detailItem?['text'] ?? ''} : ${detailItem?['text_reponse'] ?? ''}",
                                                softWrap: true,
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                String? valueUpdated;
                                                final _keyForm =
                                                    GlobalKey<FormState>();
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    actions: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(); // Close the dialog
                                                            },
                                                            child: Text(
                                                                "Annuler"), // Translated "cancel" to French
                                                          ),
                                                          TextButton(
                                                            onPressed:
                                                                () async {
                                                              print(
                                                                  valueUpdated);
                                                              int res;

                                                              if (valueUpdated !=
                                                                  null) {
                                                                res = await db()
                                                                    .updat(
                                                                        "UPDATE `reponse` SET  `text_reponse`='${valueUpdated}' WHERE id= ${detailItem?['id']} ; ");
                                                                print(
                                                                    "$res reponse updated ");
                                                                if (res > 0) {
                                                                  setState(() {
                                                                    fetchDateList();
                                                                    fetchResponseDetails(
                                                                        responseDate);
                                                                    fetchInfraList(
                                                                        responseDate);
                                                                    print(
                                                                        "done");
                                                                    valueUpdated =
                                                                        null;
                                                                  });
                                                                }
                                                              }
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(); // Close the dialog or navigate back
                                                            },
                                                            child: Text(
                                                                'Modifier'), // Translated "modify" to French
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                    title: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                              " ${detailItem?['text'] ?? ''} : ",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                              ),
                                                              softWrap: true,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start),
                                                        ),
                                                        const Icon(
                                                          Icons
                                                              .mode_edit_outline_outlined,
                                                        ),
                                                      ],
                                                    ),
                                                    content: Form(
                                                      key: _keyForm,
                                                      child: TextFormField(
                                                        initialValue:
                                                            "${detailItem?['text_reponse'] ?? ''}",
                                                        onChanged: (value) {
                                                          print(value);
                                                          valueUpdated = value;
                                                        },
                                                        validator: (value) {
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            20.0),
                                                  ),
                                                );
                                              },
                                              icon: Icon(
                                                Icons
                                                    .mode_edit_outline_outlined,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                : Center(child: CircularProgressIndicator()),
                          ],
                          onExpansionChanged: (bool expanded) {
                            setState(() {
                              if (expanded) {
                                expandedDate = responseDate;
                                fetchResponseDetails(responseDate);
                                fetchInfraList(responseDate);
                              } else if (expandedDate == responseDate) {
                                expandedDate = null;
                              }
                            });
                          },
                        ),
                        if (isExpanded)
                          ExpansionTile(
                            title: Text("Infrastructures"),
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: infraList.length,
                                itemBuilder: (context, index) {
                                  var infraItem = infraList[index];
                                  return ListTile(
                                    subtitle: Text(
                                        """ Nombre Fonctionnelles: ${infraItem['NombreFonctionnelles']} \n Nombre non Fonctionnelles: ${infraItem['NombreNonFonctionnelles']} \n Nombre totale : ${infraItem['NombreTotal']} \n  """),
                                    title: Text("  ${infraItem['nom']} :"),
                                  );
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => Divider(),
            ),
    );
  }
}
