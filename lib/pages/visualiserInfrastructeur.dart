import 'package:flutter/material.dart';
import '../db.dart';

class VisualiserInfra extends StatefulWidget {
  final int idVillage;
  final int idFormulaire;

  const VisualiserInfra({Key? key, this.idVillage = 0, this.idFormulaire = 0})
      : super(key: key);

  @override
  State<VisualiserInfra> createState() => _VisualiserState();
}

class _VisualiserState extends State<VisualiserInfra> {
  List<Map<String, dynamic>> dateList = [];
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
          "SELECT infrastructuresvillage_Online.date_info, user.nom, user.prenom FROM infrastructuresvillage_Online, infrastructur,user WHERE infrastructuresvillage_Online.NumeroVillage=${widget.idVillage} AND infrastructuresvillage_Online.user=user.id    GROUP BY date_info");
      setState(() {
        dateList = res;
        print(" les date est : ${res}");
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> fetchResponseDetails(String responseDate) async {
    try {
      if (!responseDetails.containsKey(responseDate)) {
        List<Map<String, dynamic>> res = await db().select(
            "SELECT infrastructuresvillage_Online.*,infrastructur.nom AS infrastructur  FROM infrastructuresvillage_Online,infrastructur  WHERE infrastructuresvillage_Online.TypeInfrastructure=infrastructur.id and  NumeroVillage=${widget.idVillage}    and  infrastructuresvillage_Online.date_info='$responseDate'");
        setState(() {
          responseDetails[responseDate] = res;
          print(res);
          // for (var entry in responseDetails.entries) {
          //   String responseDate = entry.key;
          //   List<Map<String, dynamic>> detailsList = entry.value;

          //   print('Response Date: $responseDate');
          //   for (var detail in detailsList) {
          //     print(detail);
          //   }
          // }
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
                String responseDate = item['date_info'];
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
                          "${responseDate} Collecté par ${item['nom']} ${item['prenom']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        ExpansionTile(
                          title: Text(" "),
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
                                            "${detailItem?['infrastructur']} :  NombreFonctionnelles est  ${detailItem?['NombreFonctionnelles']}, Nombre non Fonctionnelles est ${detailItem?['NombreNonFonctionnelles']} , totale  ${detailItem?['NombreTotal']} "),
                                        // "${detailItem?['text'] ?? ''} :  ${detailItem?['text_reponse'] ?? ''} "),
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
