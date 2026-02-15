import 'package:flutter/material.dart';
import 'package:chamDTech_nrcs/features/stories/views/widgets/nrcs_layout.dart';

class MasterManagementScreen extends StatelessWidget {
  final String title;
  
  const MasterManagementScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return NRCSAppShell(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '$title Management coming soon',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
