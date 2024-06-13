/// The CSS used in the HTML file that is generated for the timeline.
const timelineCSS = '''
:root {
  --spot-grey: #4a4a4a;
  --spot-green: #557783;
  --spot-background: #F0FCFF;
  --spot-orange: #C97B2D;
  --event-box-height: 170px;
  --thumbnail-height: 150px;
  --font-family: "Google Sans Text","Google Sans","Roboto",sans-serif;
  --font-color: var(--spot-green);
  --h1-font-size: 36px;
  --h1-padding-left: 10px;
  --border-color: var(--spot-orange);
  --border-width: 2px;
  --event-margin: 10px;
  --event-padding: 10px;
  --event-details-margin-left: 20px;
  --event-details-padding: 5px 0;
  --thumbnail-border: 1px solid var(--spot-green);
  --modal-background-color: rgba(0,0,0,0.9);
  --close-color: white;
  --close-font-size: 40px;
  --close-hover-color: var(--spot-orange);
  --nav-color: white;
  --nav-background-color: transparent;
  --nav-font-size: 30px;
  --nav-hover-color: var(--spot-orange);
  --caption-color: #ccc;
  --caption-padding: 10px 0;
  --horizontal-spacer-border-color: var(--spot-orange);
  --horizontal-spacer-padding-top: 25px;
  --button-background-color: var(--spot-green);
  --button-color: white;
  --button-hover-background-color: var(--spot-orange);
  --button-padding: 10px 20px;
  --button-font-size: 16px;
  --button-border-radius: 5px;
  --snackbar-background-color: var(--spot-orange);
  --snackbar-color: white;
  --snackbar-font-size: 17px;
}

* {
    font-family: var(--font-family);
    background-color: var(--spot-background);
    -webkit-font-smoothing: antialiased;
}

body {
  margin: 10;
}

h1, h2, h3, p {
  color: var(--font-color);
}

h1 {
  font-weight: 400;
  font-size: var(--h1-font-size);
  padding-left: var(--h1-padding-left);
}

.header {
  display: flex;
  align-items: center;
}

.event {
  display: flex;
  align-items: center;
  border: var(--border-width) solid var(--border-color);
  margin: var(--event-margin);
  padding: var(--event-padding);
  height: var(--event-box-height);
}

.event-details {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  margin-left: var(--event-details-margin-left);
  height: 100%;
}

.event-details p {
  margin: 0;
  padding: var(--event-details-padding);
  flex-grow: 1;
}

.thumbnail {
  height: var(--thumbnail-height);
  cursor: pointer;
  border: var(--thumbnail-border);
  object-fit: contain;
}

.modal {
  display: none;
  position: fixed;
  z-index: 1;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  overflow: auto;
  background-color: var(--modal-background-color);
}

.modal img {
max-width: 800px;
}

.modal span {
  background-color: transparent;
}

.modal-content {
  margin: auto;
  display: block;
  max-width: 80%;
  height: auto;
  background-color: transparent;
  border: none;
}

.close {
  position: absolute;
  top: 15px;
  right: 35px;
  color: var(--close-color);
  font-size: var(--close-font-size);
  font-weight: bold;
}

.close:hover, .close:focus {
  color: var(--close-hover-color);
  text-decoration: none;
  cursor: pointer;
}

.nav {
  position: absolute;
  top: 50%;
  font-weight: bold;
  font-size: var(--nav-font-size);
  cursor: pointer;
  user-select: none;
  color: var(--nav-color);
  background-color: var(--nav-background-color);
  transform: translateY(-50%);
  padding: 10px;
}

.nav:hover {
  color: var(--nav-hover-color);
}

.nav-left {
  left: 0;
}

.nav-right {
  right: 0;
}

#caption {
  text-align: center;
  color: var(--caption-color);
  background-color: transparent;
  padding: var(--caption-padding);
  height: 150px;
}

#caption div {
  background-color: transparent;
}

.horizontal-spacer {
  border-bottom: 1px solid var(--horizontal-spacer-border-color);
  padding-top: var(--horizontal-spacer-padding-top);
}

.horizontal-spacer h2 {
  margin: 0;
  padding: 0;
}

.button-spot {
  background-color: var(--button-background-color);
  color: var(--button-color);
  border: none;
  border-radius: var(--button-border-radius);
  padding: var(--button-padding);
  font-size: var(--button-font-size);
  cursor: pointer;
  transition: background-color 0.3s ease, color 0.3s ease;
}

.button-spot:hover {
  background-color: var(--button-hover-background-color);
}

.snackbar {
  display: none;
  min-width: 250px;
  margin-left: -125px;
  background-color: var(--snackbar-background-color);
  color: var(--snackbar-color);
  text-align: center;
  border-radius: 2px;
  padding: 16px;
  position: fixed;
  z-index: 1;
  left: 50%;
  bottom: 30px;
  font-size: var(--snackbar-font-size);
}

.snackbar.show {
  display: block;
  -webkit-animation: fadein 0.5s, fadeout 0.5s 2.5s;
  animation: fadein 0.5s, fadeout 0.5s 2.5s;
}

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