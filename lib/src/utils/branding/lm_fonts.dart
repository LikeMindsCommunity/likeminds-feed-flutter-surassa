part of 'lm_branding.dart';

class LMFonts {
  String _regular = '';
  String _medium = '';
  String _bold = '';

  LMFonts._(String regular, String medium, String bold) {
    _regular = regular;
    _bold = bold;
    _medium = medium;
  }

  String get regular => _regular;

  String get medium => _medium;

  String get bold => _bold;
}

class LMFontsBuilder {
  String _regular = '';
  String _medium = '';
  String _bold = '';

  void regular(String regular) {
    _regular = regular;
  }

  void medium(String medium) {
    _medium = medium;
  }

  void bold(String bold) {
    _bold = bold;
  }

  LMFonts build() => LMFonts._(_regular, _medium, _bold);
}
