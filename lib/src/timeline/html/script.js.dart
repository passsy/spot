// language=javascript
/// The script used in the HTML file that is generated for the timeline.
const String timelineJS = '''

let currentIndex = 0;
const events = [
  {{events}}
];

/**
 * Copies the test command to the clipboard and shows a SnackBar with the result.
 */
function copyTestCommandToClipboard() {
    var command = `flutter test --plain-name="{testName}"`;
    navigator.clipboard.writeText(command).then(function() {
        showSnackbar("Test command copied to clipboard");
    }, function(err) {
        showSnackbar("Failed to copy test command");
    });
}

/**
 * Displays a SnackBar with a specified message.
 * @param {string} message - The message to display in the SnackBar.
 */
function showSnackbar(message) {
    var snackbar = document.getElementById("snackbar");
    snackbar.textContent = message;
    snackbar.className = "snackbar show";
    setTimeout(function() {
        snackbar.className = snackbar.className.replace("show", "");
    }, 3000);
}

/**
 * Opens a modal to display an image and its caption.
 * @param {number} index - The index of the image to display.
 */
function openModal(index) {
    currentIndex = index;
    var modal = document.getElementById("myModal");
    var modalImg = document.getElementById("img01");
    var captionText = document.getElementById("captionText");
    modal.style.display = "block";
    modalImg.src = events[index].src;
    captionText.innerHTML = events[index].title;
}

/**
 * Closes the modal.
 */
function closeModal() {
    var modal = document.getElementById("myModal");
    modal.style.display = "none";
}

/**
 * Shows the previous image in the modal.
 */
function showPrev() {
    currentIndex = (currentIndex + events.length - 1) % events.length;
    updateModal();
}

/**
 * Shows the next image in the modal.
 */
function showNext() {
    currentIndex = (currentIndex + 1) % events.length;
    updateModal();
}

/**
 * Updates the modal content to display the current image and caption.
 */
function updateModal() {
    var modalImg = document.getElementById("img01");
    var captionText = document.getElementById("captionText");
    modalImg.src = events[currentIndex].src;
    captionText.innerHTML = events[currentIndex].title;
}

/**
 * Closes the modal when clicking outside of it.
 * @param {Event} event - The event triggered by the click.
 */
window.onclick = function(event) {
    var modal = document.getElementById("myModal");
    if (event.target == modal) {
        modal.style.display = "none";
    }
}

/**
 * Adds keyboard navigation for the modal.
 * @param {Event} event - The event triggered by the key press.
 */
window.addEventListener("keydown", function(event) {
    if (event.key === "ArrowLeft") {
        showPrev();
        event.preventDefault();
        event.stopPropagation();
    } else if (event.key === "ArrowRight") {
        showNext();
        event.preventDefault();
        event.stopPropagation();
    } else if (event.key === "Escape") {
        closeModal();
        event.preventDefault();
        event.stopPropagation();
    }
});

/**
 * Expands or collapses the content when clicking the "Show more" button.
 */
 document.addEventListener('DOMContentLoaded', function () {
      const contentContainers = document.querySelectorAll('.content');
      
      contentContainers.forEach((content, index) => {
        const showMoreButton = document.createElement('div');
        showMoreButton.classList.add('show-more');
        showMoreButton.innerHTML = 'Show more &#9660'; // Use &#9650; for chevron-up
        content.parentNode.insertBefore(showMoreButton, content.nextSibling);

        showMoreButton.addEventListener('click', function () {
          if (content.style.maxHeight) {
            content.style.maxHeight = null;
            showMoreButton.innerHTML = 'Show more &#9660';
          } else {
            content.style.maxHeight = content.scrollHeight + 'px';
            showMoreButton.innerHTML = 'Show less &#9650'; 
          }
        });
      });
    });
''';
