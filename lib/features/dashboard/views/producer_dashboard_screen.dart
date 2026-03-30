// features/dashboard/views/producer_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';

class ProducerDashboardScreen extends StatelessWidget {
  const ProducerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NRCSAppShell(
      title: 'Producer Dashboard',
      toolbar: const NRCSToolbar(),
      body: SelectionArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Rundowns & Story Pool',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: NRCSColors.topNavBlue,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Create Rundown'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NRCSColors.topNavBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildSection(
                    title: 'Active Rundowns',
                    icon: Icons.view_list,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: _buildSection(
                    title: 'Ready-to-Air Pool',
                    icon: Icons.pool,
                  ),
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildSection({required String title, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NRCSColors.borderGray),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: NRCSColors.topNavBlue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: NRCSColors.topNavBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Text(
                'Empty',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
