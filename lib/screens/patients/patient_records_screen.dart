import 'package:flutter/material.dart';

class PatientRecordState extends StatefulWidget {
  const PatientRecordState({super.key});

  @override
  State<PatientRecordState> createState()=> PatientRecord();
}

class PatientRecord extends State<PatientRecordState> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F7F4),
      appBar: AppBar(
        title: Text(
          "History",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia'
          )
        ),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFFB47A00),
      ),
      body: SafeArea(child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 10,
          children: [

            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border:Border.all(color: Color(0xFFE0D5BC), width: 1), borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Appointment Records", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),

                    Text("↓", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)

                  ],
                ),
              ),
              ),
            
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border:Border.all(color: Color(0xFFE0D5BC), width: 1), borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Transaction History Records", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),

                    Text("↓", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)

                  ],
                ),
              ),
              ),

          ],
        ),
      )),
    );
  }
}