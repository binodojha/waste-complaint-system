import 'package:flutter/material.dart';

class ReportForm extends StatefulWidget {
  static String id = 'report_form';
  const ReportForm({Key? key}) : super(key: key);

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      title: Row(
        children: [
          Icon(Icons.report),
          SizedBox(
            width: 10,
          ),
          Text("Report Waste"),
        ],
      ),
      content: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(
                color: Color.fromARGB(1000, 5, 150, 105),
                Icons.title,
              ),
              hintText: "Title",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
