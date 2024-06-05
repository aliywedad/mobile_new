import 'package:flutter/material.dart';
import '../db.dart';

class Visualiser extends StatefulWidget {
  final int idVillage;
  final int idFormulaire;

  const Visualiser({Key? key, this.idVillage = 0, this.idFormulaire = 0})
      : super(key: key);

  @override
  State<Visualiser> createState() => _VisualiserState();
}

class _VisualiserState extends State<Visualiser> {
  List<Map<String, dynamic>> dateList = [];
  List<Map<String, dynamic>> infraList = [];
  Map<String, List<Map<String, dynamic>>> responseDetails = {};
  Set<String> expandedDates = Set();

  @override
  void initState() {
    super.initState();
    fetchDateList();
  }

  Future<void> fetchDateList() async {
    try {
      List<Map<String, dynamic>> res = await db().select(
          "SELECT reponse_online.response_date, user.nom, user.prenom FROM reponse_online, user WHERE village=${widget.idVillage} AND reponse_online.question_id in (select id from question where formilair_id =55)  and user.id=reponse_online.id_user GROUP BY response_date");
      setState(() {
        dateList = res;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> fetchInfraList(responseDate) async {
    try {
      List<Map<String, dynamic>> ifra = await db().select(
          "SELECT infrastructuresvillage_Online.*,infrastructur.nom AS infrastructur  FROM infrastructuresvillage_Online,infrastructur  WHERE infrastructuresvillage_Online.TypeInfrastructure=infrastructur.id and  NumeroVillage=${widget.idVillage}    and  infrastructuresvillage_Online.date_info='$responseDate'");
      setState(() {
        infraList = ifra;
        print(infraList);
      });
    } catch (e) {
      print("Error fetching infrastructure list: $e");
    }
  }

  Future<void> fetchResponseDetails(String responseDate) async {
    try {
      if (!responseDetails.containsKey(responseDate)) {
        List<Map<String, dynamic>> res = await db().select(
            "SELECT reponse_online.*, user.nom, user.prenom, question.text FROM reponse_online,question ,user WHERE village=${widget.idVillage} AND reponse_online.question_id in (select id from question where formilair_id =55) and   user.id=reponse_online.id_user AND question.id=reponse_online.question_id and  reponse_online.response_date='$responseDate'");
        setState(() {
          responseDetails[responseDate] = res;
          for (var entry in responseDetails.entries) {
            String responseDate = entry.key;
            List<Map<String, dynamic>> detailsList = entry.value;

            print('Response Date: $responseDate');
            for (var detail in detailsList) {
              print(detail);
            }
          }
        });
      }
    } catch (e) {
      print("Error fetching response details: $e");
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
          ? Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: dateList.length,
              itemBuilder: (context, index) {
                var item = dateList[index];
                String responseDate = item['response_date'];
                return ListTile(
                  title: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                        Text(
                          "${responseDate.replaceAll('T', ' ').replaceAll('Z', '')} \n Collecté par ${item['nom']} ${item['prenom']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        ExpansionTile(
                          title: Text("Détails"),
                          trailing: Icon(
                            expandedDates.contains(responseDate)
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
                                        title: Text(
                                            "${detailItem?['text'] ?? ''} :  ${detailItem?['text_reponse'] ?? ''} "),
                                      );
                                    },
                                  )
                                : Center(child: CircularProgressIndicator()),
                          ],
                          onExpansionChanged: (bool expanded) {
                            setState(() {
                              if (expanded) {
                                expandedDates.add(responseDate);
                                fetchResponseDetails(responseDate);
                                fetchInfraList(responseDate);
                              } else {
                                expandedDates.remove(responseDate);
                              }
                            });
                          },
                        ),
                        ExpansionTile(
                            title: Text("Infrastructures"),
                          trailing: Icon(
                            expandedDates.contains(responseDate)
                                ? Icons.arrow_drop_down_circle
                                : Icons.arrow_drop_down,
                          ),
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
                          onExpansionChanged: (bool expanded) {
                            setState(() {
                              if (expanded) {
                                expandedDates.add(responseDate);
                                fetchResponseDetails(responseDate);
                              } else {
                                expandedDates.remove(responseDate);
                              }
                            });
                          },
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
