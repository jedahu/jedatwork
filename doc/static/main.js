document.addEventListener('DOMContentLoaded', function() {
    let toc = document.getElementById('table-of-contents');
    if (toc) {
        let tocH = toc.querySelector('h2');
        tocH.addEventListener('click', function() {
            toc.classList.toggle('show');
        });
    }
});
