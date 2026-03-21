import 'package:flutter/material.dart';
import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';

class MasterManagementScreen extends StatelessWidget {
  final String title;
  
  const MasterManagementScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return NRCSAppShell(
      title: title,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: NRCSColors.primaryBlue.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              '$title Management coming soon',
              style: const TextStyle(color: NRCSColors.textDark, fontWeight: FontWeight.w500),
            ),

          ],
        ),
      ),
    );
  }
}
