import 'fingerpicking_pattern.dart';
import 'strumming_pattern.dart';

/// Einheitlicher Verweis auf Schlag- oder Zupfmuster (für Songs/Lektionen).
sealed class TechniquePattern {
  const TechniquePattern();

  String get id;
  String get title;
  String get summary;
  int get beatsPerBar;
  int get eighthCount;
}

/// Wrapper um [StrummingPattern].
final class StrumTechnique extends TechniquePattern {
  const StrumTechnique(this.pattern);

  final StrummingPattern pattern;

  @override
  String get id => pattern.id;
  @override
  String get title => pattern.title;
  @override
  String get summary => pattern.summary;
  @override
  int get beatsPerBar => pattern.beatsPerBar;
  @override
  int get eighthCount => pattern.eighthCount;
}

/// Wrapper um [FingerpickingPattern].
final class PickTechnique extends TechniquePattern {
  const PickTechnique(this.pattern);

  final FingerpickingPattern pattern;

  @override
  String get id => pattern.id;
  @override
  String get title => pattern.title;
  @override
  String get summary => pattern.summary;
  @override
  int get beatsPerBar => pattern.beatsPerBar;
  @override
  int get eighthCount => pattern.eighthCount;
}
