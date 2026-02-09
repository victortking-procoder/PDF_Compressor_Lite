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
            Center(
              child: Text(
                'Effective Date: February 9, 2026',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Thank you for using our application ("the App"). Your privacy is important to us, and we are committed to protecting your information. This Privacy Policy explains how the App handles data, what permissions are required, and how third-party services may interact with users.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. Information We Collect',
              'The App is designed to prioritize user privacy. We do not collect, store, or transmit personal data to external servers.\n\nAll PDF compression and processing occur locally on your device. Your files remain under your control and are never uploaded or shared.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '2. Permissions',
              'The App may request the following permission:\n\nStorage Access: Used solely to read, modify, and save PDF files on your device so that compression features function properly.\n\nWe do not access any files unrelated to the App\'s functionality, and we do not collect personal information from your device.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '3. Advertising and Third-Party Services',
              'The App uses Google AdMob to display advertisements. AdMob may collect certain information automatically to provide personalized or non-personalized ads, such as:\n\n• Device information\n• Anonymous usage data\n• Advertising identifiers\n\nThis data is handled directly by Google in accordance with their privacy practices. We encourage you to review Google\'s Privacy Policy for more details:\n\nhttps://policies.google.com/privacy\n\nWe do not control how Google collects or uses this data.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '4. Data Storage',
              'Any app-related data, such as compression history, is stored locally on your device. You may delete this data at any time from within the App or by clearing the app\'s storage through your device settings.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '5. Data Security',
              'Because files are processed locally and not transmitted externally, the risk of unauthorized access is minimized. However, users are responsible for maintaining the security of their own devices.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '6. Children\'s Privacy',
              'The App is not directed toward children under the age of 13. We do not knowingly collect personal information from children. If you believe a child has provided personal data, please contact us so we can take appropriate action.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '7. Changes to This Privacy Policy',
              'We may update this Privacy Policy from time to time. Any changes will be reflected on this page with an updated effective date. Continued use of the App after updates constitutes acceptance of the revised policy.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              '8. Contact Us',
              'If you have any questions, concerns, or suggestions regarding this Privacy Policy, please contact us at:\n\nbenitanwanna@peratechsolutions.com',
            ),
            const SizedBox(height: 32),
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
