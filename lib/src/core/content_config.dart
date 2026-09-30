import 'package:flutter/material.dart';

class LocalizedText {
  const LocalizedText(this.values);

  final Map<String, String> values;

  String valueFor(Locale locale) {
    final key = locale.languageCode.toLowerCase();
    if (values.containsKey(key)) {
      return values[key]!;
    }

    if (values.containsKey('en')) {
      return values['en']!;
    }

    for (final value in values.values) {
      return value;
    }

    return '';
  }
}

class ResolvedContent {
  const ResolvedContent({
    required this.welcomeTitle,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.legalConsentText,
    required this.privacySummary,
    required this.termsSummary,
    required this.supportEmail,
    required this.supportPhone,
    required this.supportWhatsapp,
    required this.appDescription,
  });

  final String welcomeTitle;
  final String heroTitle;
  final String heroSubtitle;
  final String legalConsentText;
  final String privacySummary;
  final String termsSummary;
  final String supportEmail;
  final String supportPhone;
  final String supportWhatsapp;
  final String appDescription;
}

class ContentConfig {
  const ContentConfig({
    this.welcomeTitle = const LocalizedText({
      'en': 'Welcome',
      'id': 'Selamat datang',
    }),
    this.heroTitle = const LocalizedText({
      'en': 'Manage everything in one place',
      'id': 'Kelola semuanya dalam satu tempat',
    }),
    this.heroSubtitle = const LocalizedText({
      'en': 'Everything you need, designed for speed.',
      'id': 'Semua yang Anda butuhkan, dirancang untuk kecepatan.',
    }),
    this.legalConsentText = const LocalizedText({
      'en': 'By continuing, you agree to our terms and privacy policy.',
      'id': 'Dengan melanjutkan, Anda menyetujui syarat dan kebijakan privasi kami.',
    }),
    this.privacySummary = const LocalizedText({
      'en': 'We protect your data and respect your privacy.',
      'id': 'Kami melindungi data Anda dan menghormati privasi Anda.',
    }),
    this.termsSummary = const LocalizedText({
      'en': 'Please read our terms before using the app.',
      'id': 'Silakan baca syarat kami sebelum menggunakan aplikasi.',
    }),
    this.supportEmail = '',
    this.supportPhone = '',
    this.supportWhatsapp = '',
    this.appDescription = const LocalizedText({
      'en': 'A modern app built for daily life.',
      'id': 'Aplikasi modern untuk kehidupan sehari-hari.',
    }),
  });

  final LocalizedText welcomeTitle;
  final LocalizedText heroTitle;
  final LocalizedText heroSubtitle;
  final LocalizedText legalConsentText;
  final LocalizedText privacySummary;
  final LocalizedText termsSummary;
  final String supportEmail;
  final String supportPhone;
  final String supportWhatsapp;
  final LocalizedText appDescription;

  String welcomeTitleFor(Locale locale) => welcomeTitle.valueFor(locale);

  String heroTitleFor(Locale locale) => heroTitle.valueFor(locale);

  String heroSubtitleFor(Locale locale) => heroSubtitle.valueFor(locale);

  String legalConsentTextFor(Locale locale) => legalConsentText.valueFor(locale);

  String privacySummaryFor(Locale locale) => privacySummary.valueFor(locale);

  String termsSummaryFor(Locale locale) => termsSummary.valueFor(locale);

  String appDescriptionFor(Locale locale) => appDescription.valueFor(locale);

  ResolvedContent contentFor(Locale locale) => ResolvedContent(
    welcomeTitle: welcomeTitleFor(locale),
    heroTitle: heroTitleFor(locale),
    heroSubtitle: heroSubtitleFor(locale),
    legalConsentText: legalConsentTextFor(locale),
    privacySummary: privacySummaryFor(locale),
    termsSummary: termsSummaryFor(locale),
    supportEmail: supportEmail,
    supportPhone: supportPhone,
    supportWhatsapp: supportWhatsapp,
    appDescription: appDescriptionFor(locale),
  );
}
