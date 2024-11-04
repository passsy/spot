String buildPubspecString(String name, bool addFontsFolder) {
  return '''
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

flutter:
  assets:
    - fonts/
''';
}
