import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Tost {




  void alert(BuildContext context, String message ,Color color,IconData icon) {
    FToast fToast = FToast();
    fToast.init(context);
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        
        color:  color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            // Icons.warning,
            color: Colors.white,
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      toastDuration: const Duration(seconds: 3),
      
      gravity: ToastGravity.TOP,
    );
  }
}
