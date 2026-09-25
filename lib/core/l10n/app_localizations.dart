import 'package:flutter/material.dart';
import 'translations_en.dart';
import 'translations_zh_cn.dart';
import 'translations_zh_tw.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('zh', 'CN'),
    Locale('zh', 'TW'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  late final Map<String, String> _localizedStrings = _loadTranslations();

  Map<String, String> _loadTranslations() {
    if (locale.languageCode == 'zh') {
      if (locale.countryCode == 'TW' || locale.countryCode == 'HK' || locale.scriptCode == 'Hant') {
        return translationsZhTw;
      }
      return translationsZhCn;
    }
    return translationsEn;
  }

  String tr(String key) {
    return _localizedStrings[key] ?? key;
  }

  String get currentLanguageCode {
    if (locale.languageCode == 'zh') {
      if (locale.countryCode == 'TW' || locale.countryCode == 'HK' || locale.scriptCode == 'Hant') {
        return 'zh_TW';
      }
      return 'zh_CN';
    }
    return 'en';
  }

  String get currentLanguageLabel {
    if (locale.languageCode == 'zh') {
      if (locale.countryCode == 'TW' || locale.countryCode == 'HK' || locale.scriptCode == 'Hant') {
        return '繁';
      }
      return '简';
    }
    return 'EN';
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsExtension on BuildContext {
  String tr(String key) => AppLocalizations.of(this).tr(key);
  AppLocalizations get loc => AppLocalizations.of(this);
}
