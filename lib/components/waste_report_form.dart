import 'package:flutter/material.dart';
import 'package:swms/components/map_google.dart';

class ReportForm extends StatefulWidget {
  static String id = 'report_form';
  const ReportForm({super.key});

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  void updateLocation(String newLocation) {
    locationController.text = newLocation;
  }

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
          Text("Report A Waste"),
        ],
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            maxLength: 20,
            decoration: InputDecoration(
              hintText: "Title",
              // labelText: "Title",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          TextField(
            controller: descriptionController,
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Description",
              // labelText: "Title",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: locationController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: "Location",
              // labelText: "Title",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 300,
            child: Map(
              onLocationSelected: updateLocation,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
                padding: EdgeInsets.all(15),
                shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                foregroundColor: Colors.white,
                backgroundColor: Color.fromARGB(1000, 5, 150, 105),
              ),
              child: Text("Submit"),
            ),
          ),
        ],
      ),
    );
  }
}
