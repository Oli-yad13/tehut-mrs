// Tihut Clinic Branding Override
(function() {
    'use strict';

    // Remove unwanted text on page load
    function removeUnwantedText() {
        // Remove specific text nodes
        var walker = document.createTreeWalker(
            document.body,
            NodeFilter.SHOW_TEXT,
            null,
            false
        );

        var nodesToRemove = [];
        while (walker.nextNode()) {
            var node = walker.currentNode;
            var text = node.nodeValue.trim();

            // Check if text contains unwanted strings
            if (text === 'TITLE TEXT' ||
                text === 'WELCOME TO' ||
                text === 'BAHMNI EMR & HOSPITAL SERVICE' ||
                text.includes('TITLE TEXT') ||
                text.includes('WELCOME TO') ||
                text.includes('BAHMNI EMR & HOSPITAL SERVICE')) {
                nodesToRemove.push(node);
            }
        }

        // Remove the nodes
        nodesToRemove.forEach(function(node) {
            if (node.parentNode) {
                node.parentNode.removeChild(node);
            }
        });

        // Also hide elements containing this text
        var allElements = document.querySelectorAll('*');
        allElements.forEach(function(el) {
            var text = el.textContent.trim();
            if ((text === 'TITLE TEXT' ||
                 text === 'WELCOME TO' ||
                 text === 'BAHMNI EMR & HOSPITAL SERVICE' ||
                 text === 'WELCOME TO BAHMNI EMR & HOSPITAL SERVICE') &&
                !el.querySelector('img') &&
                !el.classList.contains('apps')) {
                el.style.display = 'none';
            }
        });
    }

    // Run on page load
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', removeUnwantedText);
    } else {
        removeUnwantedText();
    }

    // Also run periodically to catch dynamically loaded content
    setInterval(removeUnwantedText, 500);

    // Watch for Angular digest cycles
    if (window.angular) {
        angular.element(document).ready(function() {
            setTimeout(removeUnwantedText, 1000);
            setTimeout(removeUnwantedText, 2000);
            setTimeout(removeUnwantedText, 3000);
        });
    }
})();