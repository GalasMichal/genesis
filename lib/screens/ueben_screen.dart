import 'package:flutter/material.dart';

/// Platzhalter für den Übungs-Modus mit Mic-Check (P3).
class UebenScreen extends StatelessWidget {
  const UebenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Üben')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mic-Check',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Hier übst du Noten und Griffe mit dem Mikrofon. '
                'Die App zeigt dir den Zielton und signalisiert, '
                'wenn du richtig gespielt hast — ehrliches Feedback, kein Durchwinken.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.45,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Geplant',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Einzelnoten-Erkennung zuerst, Tempo-Regler und kurze Loops. '
                'Akkord-Erkennung folgt später als Stretch-Ziel.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
