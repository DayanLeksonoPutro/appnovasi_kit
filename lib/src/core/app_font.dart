class AppFont {
  const AppFont({required this.name, this.fontFamily});

  final String name;
  final String? fontFamily;
}

const List<AppFont> defaultFonts = [
  AppFont(name: 'Default'),
  AppFont(name: 'Inter', fontFamily: 'Inter'),
  AppFont(name: 'Poppins', fontFamily: 'Poppins'),
  AppFont(name: 'Manrope', fontFamily: 'Manrope'),
  AppFont(name: 'Lexend', fontFamily: 'Lexend'),
  AppFont(name: 'Serif', fontFamily: 'serif'),
  AppFont(name: 'Monospace', fontFamily: 'monospace'),
];
