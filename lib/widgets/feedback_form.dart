import 'package:beta_app/modules/logging/providers/i_logging_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeedbackForm extends StatelessWidget {
  final TextEditingController _feedbackController = TextEditingController();

  FeedbackForm({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = Provider.of<ILoggingProvider>(context, listen: false);

    return AlertDialog(
      title: Text('Feedback'),
      content: TextField(
        controller: _feedbackController,
        decoration: InputDecoration(hintText: "Enter your feedback"),
      ),
      actions: [
        TextButton(
          onPressed: () {
            String feedback = _feedbackController.text;
            if (feedback.isNotEmpty) {
              logger.logInfo('User Feedback: $feedback');
              Navigator.of(context).pop();
            }
          },
          child: Text('Submit'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
