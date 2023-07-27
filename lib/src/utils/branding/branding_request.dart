part of 'lm_branding.dart';

class SetBrandingRequest {
  String _headerColor = "#FFFFFF";
  String _buttonsColor = "#5046E5";
  String _textLinkColor = "#007AFF";
  LMFonts? _fonts;

  SetBrandingRequest._(String headerColor, String buttonsColor,
      String textLinkColor, LMFonts? fonts) {
    _headerColor = headerColor;
    _buttonsColor = buttonsColor;
    _textLinkColor = textLinkColor;
    _fonts = fonts;
  }

  String get headerColor => _headerColor;

  String get buttonsColor => _buttonsColor;

  String get textLinkColor => _textLinkColor;

  LMFonts? get fonts => _fonts;
}

class SetBrandingRequestBuilder {
  String _headerColor = "#FFFFFF";
  String _buttonsColor = "#5046E5";
  String _textLinkColor = "#007AFF";
  LMFonts? _fonts;

  void headerColor(String headerColor) {
    _headerColor = headerColor;
  }

  void buttonsColor(String buttonsColor) {
    _buttonsColor = buttonsColor;
  }

  void textLinkColor(String textLinkColor) {
    _textLinkColor = textLinkColor;
  }

  void fonts(LMFonts fonts) {
    _fonts = fonts;
  }

  SetBrandingRequest build() =>
      SetBrandingRequest._(_headerColor, _buttonsColor, _textLinkColor, _fonts);
}
