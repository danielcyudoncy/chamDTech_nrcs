import 'package:flutter/material.dart';
import 'package:chamDTech_nrcs/features/stories/views/widgets/nrcs_layout.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';

class AnchorDashboardScreen extends StatelessWidget {
  const AnchorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NRCSAppShell(
      title: 'Anchor Dashboard',
      toolbar: const NRCSToolbar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mic_external_on,
              size: 64,
              color: NRCSColors.topNavBlue,
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome, Anchor!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: NRCSColors.topNavBlue,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your localized read-only rundown feed will appear here.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
