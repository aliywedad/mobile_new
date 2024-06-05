import 'package:flutter/material.dart';

class Alerts {

  void AlertWithTwoButton(BuildContext context, String message, String Ok_message, Color color, IconData icon,) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue
                },
                child: Text("Annuler"), // Texte corrigé en français
              ),
              TextButton(
                onPressed: () async {

                  // okfunction()
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue après l'envoi
                },
                child: Text(Ok_message), // Texte corrigé en français
              ),
            ],
          ),
        ],
        title: Icon(
          icon,
          color: color,
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.black), // Couleur du texte changée en noir pour une meilleure lisibilité
        ),
        contentPadding: const EdgeInsets.all(20.0),
      ),
    );
  }




void SimpleAlert(BuildContext context, String message, String Ok_message, Color color, IconData icon,) {
  showDialog(
    context: context,
    builder: (context) {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop(true);
      });
      return AlertDialog(
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("Annuler"), // Text corrected in French
              ),
              // TextButton(
              //   onPressed: () async {
              //     // okfunction()
              //     Navigator.of(context).pop(); // Close the dialog after sending
              //   },
              //   child: Text(Ok_message), // Text corrected in French
              // ),
            ],
          ),
        ],
        title: Icon(
          icon,
          color: color,
                    size: 60.0, // Adjust the size as needed


        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.black), // Text color changed to black for better readability
        ),
        contentPadding: const EdgeInsets.all(20.0),
      );
    },
  );
}


}
