import 'package:flutter/material.dart';


class quick_solutions extends StatelessWidget {
  final List<String> solutions = [
    "1- Open room windows",
    "2- Evacuate the place from people",
    "3- Open the fans if any.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F4), // Background color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(209, 71, 102, 59),),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "We recommend quick solutions to improve CO2 levels in a short time.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: 50),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Quick Solutions",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color.fromARGB(209, 71, 102, 59),
                    ),
                  ),
                  SizedBox(height: 10),
                  ...solutions.map((solution) => _buildSolutionCard(solution)).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionCard(String solutionText) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(209, 71, 102, 59),),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        solutionText,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500 , color: Color.fromARGB(209, 71, 102, 59),),
      ),
    );
  }
}
