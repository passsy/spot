// ignore_for_file: public_member_api_docs

import 'package:jaspr/dom.dart';

// Colors

const Color spotGrey = Color('#4a4a4a');
const Color spotGreen = Color('#557783');
const Color spotBackground = Color('#F0FCFF');
const Color spotOrange = Color('#C97B2D');

// Typography

const FontFamily fontFamily = FontFamily.list([
  FontFamily('Google Sans Text'),
  FontFamily('Google Sans'),
  FontFamily('Roboto'),
  FontFamilies.sansSerif,
]);
const Color fontColor = spotGreen;
const Unit h1FontSize = Unit.pixels(36);
const Padding h1Padding = Padding.only(left: Unit.pixels(10));

// Events

const Unit eventBoxHeight = Unit.pixels(170);
const Unit thumbnailHeight = Unit.pixels(150);
const Color borderColor = spotOrange;
const Margin eventMargin = Margin.all(Unit.pixels(10));
const Padding eventPadding = Padding.all(Unit.pixels(10));
const Margin eventDetailsMargin = Margin.only(left: Unit.pixels(20));
const Padding eventDetailsPadding = Padding.symmetric(vertical: Unit.pixels(5));
const Border thumbnailBorder = Border.all(
  color: spotGreen,
  width: Unit.pixels(1),
);

// Modal

const Color modalBackgroundColor = Color.rgba(0, 0, 0, 0.9);
const Color closeColor = Colors.white;
const Unit closeFontSize = Unit.pixels(40);
const Color closeHoverColor = spotOrange;
const Color navColor = Colors.white;
const Color navBackgroundColor = Colors.transparent;
const Unit navFontSize = Unit.pixels(30);
const Color navHoverColor = spotOrange;
const Color captionColor = Color('#000000a0');
const Padding captionPadding = Padding.symmetric(vertical: Unit.pixels(10));

// Button

const Color buttonBackgroundColor = spotGreen;
const Color buttonColor = Colors.white;
const Color buttonHoverBackgroundColor = spotOrange;
const Padding buttonPadding = Padding.symmetric(
  vertical: Unit.pixels(10),
  horizontal: Unit.pixels(20),
);
const Unit buttonFontSize = Unit.pixels(16);
const BorderRadius buttonBorderRadius = BorderRadius.circular(Unit.pixels(5));

// Spacer

const Color horizontalSpacerBorderColor = spotOrange;
const Padding horizontalSpacerPadding = Padding.only(top: Unit.pixels(25));

// Snackbar

const Color snackbarBackgroundColor = spotOrange;
const Color snackbarColor = Colors.white;
const Unit snackbarFontSize = Unit.pixels(17);

// Animations

const animationsCSS = '''
@-webkit-keyframes fadein {
  from {bottom: 0; opacity: 0;}
  to {bottom: 30px; opacity: 1;}
}

@keyframes fadein {
  from {bottom: 0; opacity: 0;}
  to {bottom: 30px; opacity: 1;}
}

@-webkit-keyframes fadeout {
  from {bottom: 30px; opacity: 1;}
  to {bottom: 0; opacity: 0;}
}

@keyframes fadeout {
  from {bottom: 30px; opacity: 1;}
  to {bottom: 0; opacity: 0;}
}
''';
