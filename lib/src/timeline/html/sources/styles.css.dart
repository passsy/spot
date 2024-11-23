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
  padding-bottom: 50px;
}

h1, h2, h3, p, pre {
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
  align-items: flex-start;
  margin: var(--event-margin);
  padding: var(--event-padding);
}

.event-details {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  margin-left: var(--event-details-margin-left);
  min-width: 0;
}

.code-location {
  display: flex;
  gap: 20px;
  align-items: center;
  min-width: 0;
  flex-flow: row wrap;
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
  justify-content: center; 
  align-items: center;
}

.modal.show {
  display: block;
}

.modal img {
  max-width: 100%;
  height: auto;
}

.modal span {
  background-color: transparent;
}

.modal-content {
  margin: auto;
  display: flex;
  flex-direction: column;
  max-width: 80%;
  height: auto;
  background-color: transparent;
  border: none;
  position: relative;
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
  margin: 0 5px; 
}

.nav:hover {
  color: var(--nav-hover-color);
}

.nav-left {
  left: -50px;
}

.nav-right {
  right: -50px;
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

.bn29 {
  border: none;
  padding: 0.8em 2.5em;
  outline: none;
  color: white;
  font-style: 1.2em;
  position: relative;
  z-index: 1;
  cursor: pointer;
  background: none;
  text-shadow: 3px 3px 10px rgba(0, 0, 0, 0.45);
}

.bn29:before,
.bn29:after {
  position: absolute;
  top: 50%;
  left: 50%;
  border-radius: 10em;
  -webkit-transform: translateX(-50%) translateY(-50%);
  transform: translateX(-50%) translateY(-50%);
  width: 105%;
  height: 105%;
  content: "";
  z-index: -2;
  background-size: 400% 400%;
  background: linear-gradient(
    60deg,
    #f79533,
    #f37055,
    #ef4e7b,
    #a166ab,
    #5073b8,
    #1098ad,
    #07b39b,
    #6fba82
  );
}

.bn29:before {
  -webkit-transition: all 0.25s ease;
  transition: all 0.25s ease;
  -webkit-animation: pulse 10s infinite ease;
  animation: pulse 10s infinite ease;
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

.content {
 overflow: hidden;
 transition: max-height 0.3s ease; /* Add smooth transition effect */
}

.show-more {
 cursor: pointer;
 color: var(--spot-orange);
 display: block;
 background-color:linear-gradient(to bottom, rgba(255, 255, 255, 0.4) 0%, rgba(255, 255, 255, 1) 100% );
}

.secondary-button {
    padding: 6px 24px;
    font-size: 12px;
    font-weight: 600;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.3s ease;
    width: 100px;
}

.secondary-button--animated {
    background-color: var(--spot-orange);
    overflow: hidden;
    position: relative;
    
    span {
    background-color: transparent;
    color: white;
    }
}

.secondary-button--animated .secondary-button__text {
    display: inline-block;
    transition: transform 0.3s ease;
}

.secondary-button--animated .secondary-button__icon {
    position: absolute;
    right: -20px;
    transition: right 0.3s ease;
    
}

.secondary-button--animated:hover .secondary-button__text {
    transform: translateX(-10px);
}

.secondary-button--animated:hover .secondary-button__icon {
    right: 20px;
}
''';
