import 'package:flutter/material.dart';
import 'dart:io';

class TicketListScreen extends StatelessWidget {
  final List<String> tickets; // List of ticket image paths

  const TicketListScreen({super.key, required this.tickets});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tickets',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue[700], // Set app bar color to blue[700]
        centerTitle: true, // Center the app bar title
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade100, // Light blue at the top
              Colors.white, // White at the bottom
            ],
          ),
        ),
        child: ListView.builder(
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.all(10),
              color: Colors.white, // Semi-transparent white background
              child: ListTile(
                leading: Icon(Icons.assignment),
                title: Text('Ticket #${index + 1}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.file(File(tickets[index]), fit: BoxFit.cover), // Display the ticket image
                    SizedBox(height: 10),
                    Text(
                      'Status: Pending', // Example status
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.orange, // Orange color for status
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}