class AppFont {
  const AppFont({required this.name, this.fontFamily});

  final String name;
  final String? fontFamily;
}

const List<AppFont> defaultFonts = [
  AppFont(name: 'Default'),
  AppFont(name: 'Serif', fontFamily: 'serif'),
  AppFont(name: 'Monospace', fontFamily: 'monospace'),
];
