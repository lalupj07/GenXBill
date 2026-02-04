import 'package:flutter/material.dart';
import 'package:genx_bill/features/hr/data/models/employee_model.dart' as hr;

class EmployeeDocumentsTab extends StatelessWidget {
  final hr.HREmployee employee;
  const EmployeeDocumentsTab({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final docs = employee.documents;

    if (docs.isEmpty) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open,
              size: 64, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text("No documents uploaded yet"),
          const SizedBox(height: 16),
          ElevatedButton.icon(
              onPressed: () {
                // Implement upload
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Upload Feature coming soon")));
              },
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload Document"))
        ],
      ));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.description, color: Colors.blue),
            title: Text(doc.title),
            subtitle: Text(
                '${doc.type.name} • ${doc.uploadDate.toString().split(' ')[0]}'),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }
}
