import 'package:material_ui/material_ui.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.studentName,
    required this.onSaveName,
  });

  final String studentName;
  final Future<void> Function(String name) onSaveName;

  Future<void> _editName(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    var name = '';
    final messenger = ScaffoldMessenger.of(context);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit profile'),
        content: Form(
          key: formKey,
          child: TextFormField(
            initialValue: studentName,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Your name'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter your name.'
                : null,
            onSaved: (value) => name = value?.trim() ?? '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              formKey.currentState!.save();
              try {
                await onSaveName(name);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Profile updated.')),
                );
              } catch (error) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Could not update profile: $error')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
    children: [
      Text(
        'Your account',
        style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      const Text('Personalize your BudgetBuddy profile.'),
      const SizedBox(height: 18),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(
                  Icons.person_outline,
                  size: 32,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Text('Student'),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Edit name',
                onPressed: () => _editName(context),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      Card(
        child: Column(
          children: const [
            ListTile(
              leading: Icon(Icons.cloud_off_outlined, color: Color(0xFF2E7D32)),
              title: Text('Works offline'),
              subtitle: Text('Your information stays on this device.'),
            ),
            Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: Icon(Icons.payments_outlined, color: Color(0xFF2E7D32)),
              title: Text('Currency'),
              subtitle: Text('Philippine Peso (₱)'),
            ),
            Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: Icon(Icons.info_outline, color: Color(0xFF2E7D32)),
              title: Text('BudgetBuddy'),
              subtitle: Text('Student Budget Tracker · Version 1.0.0'),
            ),
          ],
        ),
      ),
    ],
  );
}
