import 'package:flutter/material.dart';

part 'lm_fonts.dart';
part 'branding_request.dart';

class LMBranding {
  String _headerColor = '#FFFFFF';
  String _buttonsColor = '#5046E5';
  String _textLinkColor = '#007AFF';
  LMFonts? _fonts;

  static LMBranding? _instance;
  static LMBranding get instance => _instance ??= LMBranding._();

  LMBranding._({
    String headerColor = '#FFFFFF',
    String buttonsColor = '#5046E5',
    String textLinkColor = '#007AFF',
    LMFonts? fonts,
  }) {
    _headerColor = headerColor;
    _buttonsColor = buttonsColor;
    _textLinkColor = textLinkColor;
    _fonts = fonts;
  }

  void setBranding(SetBrandingRequest setBrandingRequest) {
    _headerColor = setBrandingRequest.headerColor;
    _buttonsColor = setBrandingRequest.buttonsColor;
    _textLinkColor = setBrandingRequest.textLinkColor;
    _fonts = setBrandingRequest.fonts;
  }

  String get headerColor => _headerColor;

  String get buttonsColor => _buttonsColor;

  String get textLinkColor => _textLinkColor;

  LMFonts? get fonts => _fonts;

  Color getToolBarColor() {
    return headerColor == "#FFFFFF" ? Colors.black : Colors.white;
  }

  Color getSubtitleColor() {
    return headerColor == "#FFFFFF" ? Colors.grey : Colors.white;
  }
}
