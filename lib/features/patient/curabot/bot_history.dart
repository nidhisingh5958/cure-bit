import 'package:CuraDocs/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BotHistory extends StatelessWidget {
  const BotHistory({
    required this.text,
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      child: ListTile(
        onTap: () {
          context.push(RouteConstants.chatBotScreen);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.chat_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Theme.of(context).colorScheme.primary,
          size: 16,
        ),
      ),
    );
  }
}

const _historyItems = [
  "What is helirab-d used for?",
  "What are the symptoms of malaria?",
  "What is the dosage of paracetamol?",
  "Suggest a medicine for headache",
  "Suggest a medicine for stomachache",
  "Home remedies for treating cold",
  "What should I do to control my cholesterol?",
  "How can I treat headache?",
];
