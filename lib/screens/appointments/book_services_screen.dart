import 'package:flutter/material.dart';

class AppointmentBookState extends StatefulWidget {
  const AppointmentBookState({super.key});

  @override
  State<AppointmentBookState> createState() => AppointmentBook();
}

class AppointmentBook extends State<AppointmentBookState> {
  final Color gold =  Color(0xFFB47A00);

  final TextEditingController concernController = TextEditingController();
  String appointmentConcern = '';
  bool showAppointmentCard = false;

  final List<Map<String, dynamic>> branches = [
    {'id': 1, 'name': 'Main Branch'},
    {'id': 2, 'name': 'Quezon Branch'},
    {'id': 3, 'name': 'Pasig Branch'},
  ];

  final List<Map<String, dynamic>> services = [
    {'id': 1, 'name': 'Deep Scaling', 'price': 1500},
    {'id': 2, 'name': 'Teeth Whitening', 'price': 5000},
    {'id': 3, 'name': 'Veneers', 'price': 12000},
    {'id': 4, 'name': 'Root Canal Treatment', 'price': 8000},
    {'id': 5, 'name': 'Orthodontics', 'price': 35000},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFFF8F7F4),
      appBar: AppBar(
        title: Text(
          'Appointment Booking Assistant',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFFB47A00),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                'Select Branch',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),

              SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: branches.map((branch) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Color(0xFFE0D5BC),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      branch['name'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 24),

               Text(
                'Quick Picks Services',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),

            SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: services.map((service) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Color(0xFFE0D5BC),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      service['name'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 24),

              Text(
                'Describe your dental concern or service request',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),

              SizedBox(height: 12),

              TextField(
                controller: concernController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'Tell us about your dental concern or service request...',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Color(0xFFE0D5BC),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Color(0xFFE0D5BC),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: gold,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (concernController.text.trim().isNotEmpty)
                    {
                      setState(() {
                        appointmentConcern = concernController.text.trim();
                        showAppointmentCard = true;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              if (showAppointmentCard) ...[
                SizedBox(height: 16,),
                
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Color(0xFFE0D5BC)),
                  ),
                  child: Padding(padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Current Appointment",
                        style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Georgia', color: Color(0xFF333333)
                        ),
                      ),

                      SizedBox(height: 12,),
                      Text(
                        appointmentConcern, style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
                      ),

                      SizedBox(height: 12,),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(onPressed: () {
                          setState(() {
                            showAppointmentCard = false;
                          });
                        },
                        child: Text("Cancel", style: TextStyle(color: gold, fontWeight: FontWeight.bold),),
                        
                        ),
                      )

                    ],
                  ),
                  ),
                )
              ]

            ],
          ),
        ),
      ),
    );
  }
}
