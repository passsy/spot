String buildPubspecString(String name, bool addFontsFolder) {
  String pubspec = '''
name: $name
description: "A Flutter Test project."
publish_to: 'none'
version: 0.1.0

environment:
  sdk: '>=3.4.1 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_test:
    sdk: flutter
  spot: 
    git: 
      url: https://github.com/robiness/spot.git
      ref: main
    
dev_dependencies:
  test: ^1.24.0
''';
  if (addFontsFolder) {
    pubspec = '''$pubspec    
    
flutter:
  fonts:
    - family: Montserrat
      fonts:
        - asset: fonts/Montserrat-Regular.ttf
''';
  }
  return pubspec;
}
