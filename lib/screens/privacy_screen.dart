import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Data Processing',
              'All PDF compression happens locally on your device. Your files never leave your phone and are not sent to any server.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              'Permissions',
              'This app requests storage permissions only to access and save PDF files on your device. No other data is collected or accessed.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              'Advertising',
              'This app displays ads provided by Google AdMob. AdMob may collect anonymous usage data for ad personalization. For more information, please visit Google\'s privacy policy.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              'Data Storage',
              'The app stores compression history locally on your device. This data can be cleared at any time from the home screen.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              'Third-Party Services',
              'This app uses Google AdMob for advertising. No other third-party services have access to your files or personal data.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              'Contact',
              'If you have any questions about this privacy policy, please contact us through the app store review section.',
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Last updated: February 2026',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
