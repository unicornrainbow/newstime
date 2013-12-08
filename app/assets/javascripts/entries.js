
function expandTextarea(id) {
    var $element = $('.myclass').get(0);

    $element.addEventListener('keyup', function() {
        this.style.overflow = 'hidden';
        this.style.height = 0;
        this.style.height = this.scrollHeight + 'px';
    }, false);
}
