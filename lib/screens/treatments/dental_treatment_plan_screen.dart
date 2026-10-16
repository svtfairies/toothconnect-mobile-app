import 'package:flutter/material.dart';

class DentalPlanState extends StatefulWidget {
  const DentalPlanState({super.key});

  @override
  State<DentalPlanState> createState() => DentalPlan();
}

class DentalPlan extends State<DentalPlanState> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFFF8F7F4),
      appBar: AppBar(
        title: Text("Dental Treatment Plan", style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Georgia',
        ),),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Tooth #18", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                    Text("Treatment: Root Canal", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),

                    Text("Status: Completed", style: TextStyle(fontSize: 12,),),
                    Text("Dentist: Jane Dela Cruz", style: TextStyle(fontSize: 12,),),
                    Text("Treatment: Root Canal", style: TextStyle(fontSize: 12,),),
                    Text("Date Added: September 10, 2026", style: TextStyle(fontSize: 12,),)
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Tooth #21", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                    Text("Treatment: Filling", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),

                    Text("Status: Planned", style: TextStyle(fontSize: 12,),),
                    Text("Dentist: Jane Dela Cruz", style: TextStyle(fontSize: 12,),),
                    Text("Treatment: Root Canal", style: TextStyle(fontSize: 12)),
                    Text("Date Added: September 10, 2026", style: TextStyle(fontSize: 12,),)
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