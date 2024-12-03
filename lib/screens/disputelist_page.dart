import 'package:flutter/material.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:provider/provider.dart';

class DisputeListPage extends StatelessWidget {
  const DisputeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disputes You Submitted')),
      body: Consumer<UserProvider>(
        builder: (context, disputeProvider, child) {
          return ListView.builder(
            itemCount: disputeProvider.disputes.length,
            itemBuilder: (context, index) {
              final dispute = disputeProvider.disputes[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dispute.reason,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(dispute.description),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            // disputeProvider.removeDispute(index);
                          },
                          child: const Text(
                            'close',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
