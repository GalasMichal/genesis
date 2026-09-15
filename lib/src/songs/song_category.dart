/// Kategorien der Songbibliothek (P4).
enum SongCategory {
  beginnerExercises,
  englishTraditionals,
  polishFolk,
  classical,
  originalPopRock,
}

extension SongCategoryX on SongCategory {
  String get id => switch (this) {
        SongCategory.beginnerExercises => 'einsteiger',
        SongCategory.englishTraditionals => 'englisch',
        SongCategory.polishFolk => 'polnisch',
        SongCategory.classical => 'klassik',
        SongCategory.originalPopRock => 'eigen-pop',
      };

  /// Deutsche UI-Bezeichnung.
  String get label => switch (this) {
        SongCategory.beginnerExercises => 'Einsteiger-Übungen',
        SongCategory.englishTraditionals => 'Englische Traditionals',
        SongCategory.polishFolk => 'Polnische Volkslieder',
        SongCategory.classical => 'Klassik',
        SongCategory.originalPopRock => 'Eigen (Pop/Rock)',
      };

  String get shortLabel => switch (this) {
        SongCategory.beginnerExercises => 'Einsteiger',
        SongCategory.englishTraditionals => 'Englisch',
        SongCategory.polishFolk => 'Polnisch',
        SongCategory.classical => 'Klassik',
        SongCategory.originalPopRock => 'Pop/Rock',
      };
}
