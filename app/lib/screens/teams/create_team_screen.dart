import 'package:cricstatz/config/palette.dart';
import 'package:cricstatz/providers/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shortCodeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _shortCodeController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await context.read<TeamProvider>().createTeam(
          name: _nameController.text.trim(),
          shortCode: _shortCodeController.text.trim().toUpperCase(),
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Team')),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppPalette.surfaceGradient),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: AppPalette.textPrimary),
                  decoration: _inputDecoration('Team name', 'Enter full team name'),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Team name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _shortCodeController,
                  maxLength: 3,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(color: AppPalette.textPrimary),
                  decoration: _inputDecoration('Short code', 'Examples: IND, AUS, ENG'),
                  validator: (String? value) {
                    final String cleaned = (value ?? '').trim();
                    if (cleaned.length < 2 || cleaned.length > 3) {
                      return 'Use 2-3 characters';
                    }
                    return null;
                  },
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppPalette.accent,
                      foregroundColor: AppPalette.bgSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Save Team', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: AppPalette.textMuted),
      hintStyle: const TextStyle(color: AppPalette.textSubtle),
      filled: true,
      fillColor: AppPalette.cardOverlay,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppPalette.cardStroke),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppPalette.accent),
      ),
    );
  }
}
