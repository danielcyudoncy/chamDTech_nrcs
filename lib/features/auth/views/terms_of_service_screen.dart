// features/auth/views/terms_of_service_screen.dart
import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Last updated: [Date]',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 16),
            Text(
              'This is a placeholder for your Terms of Service. You should replace this text with your own terms. Terms of service (also known as terms of use and terms and conditions, commonly abbreviated as ToS or T&C) are the legal agreements between a service provider and a person who wants to use that service.',
              textAlign: TextAlign.justify,
            ),
            // Add more sections as needed
          ],
        ),
      ),
    );
  }
}
