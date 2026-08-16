import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import 'language_selector_sheet.dart';

class LanguageSwitcherButton extends StatelessWidget {
  final bool isCompact;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const LanguageSwitcherButton({
    super.key,
    this.isCompact = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLang = languageProvider.currentLanguage;

    final effectiveBg = backgroundColor ?? Colors.white.withOpacity(0.9);
    final effectiveText = textColor ?? const Color(0xff0A5B8E);
    final effectiveBorder = borderColor ?? const Color(0xff0A5B8E).withOpacity(0.2);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => LanguageSelectorSheet.show(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 10 : 14,
            vertical: isCompact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: effectiveBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff0A5B8E).withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language_rounded,
                size: isCompact ? 16 : 18,
                color: effectiveText,
              ),
              const SizedBox(width: 6),
              Text(
                currentLang.nativeName,
                style: TextStyle(
                  fontSize: isCompact ? 12 : 13,
                  fontWeight: FontWeight.bold,
                  color: effectiveText,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 3),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: isCompact ? 14 : 16,
                color: effectiveText.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
