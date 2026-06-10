

import 'package:flutter/material.dart';


import '../../core/constant/app_color.dart';



class Reportscreen extends StatefulWidget {
  
  const Reportscreen({super.key,});

  @override
  State<Reportscreen> createState() => _ReportscreenState();
}

class _ReportscreenState extends State<Reportscreen> {
  String employeeName = "Employee";
  String supervisorId = "123";
  String supervisor = "Team Lead";
  String email = "";


  @override
  void initState() {
    super.initState();
    
  }


  @override
  Widget build(BuildContext context) {
    return 
      
        Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.bgPage,
              scrolledUnderElevation: 0,
              excludeHeaderSemantics: true,
              title: const Text("Profile"),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[300],
                              child: const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          employeeName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                         Text(supervisor),
                        const SizedBox(height: 10),
                         Text('UAE'),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Employee Details',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Text('Name',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.normal)),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primarylight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        employeeName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Mobile Number',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.normal)),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primarylight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: const Text(
                        '+971 - 600555333',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Email ID',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.normal)),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primarylight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        email.toString(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
