Reveal.addEventListener('ready', function() {
  let footer = document.querySelector('div.footer');
  let slideNum = document.querySelector('div.slide-number');

  function updateFooter() {
    if (Reveal.isFirstSlide()) {
      slideNum.classList.add('hide');
      footer.innerHTML = "R/Medicine 2026";
      footer.style.setProperty("color", "#003F30");
    } else {
      slideNum.classList.remove('hide');
      footer.innerHTML = '<a href="https://github.com/kyleGrealis/sumExtras/tree/main/inst/slides" target="_blank">Slides link here</a>';
      footer.style.removeProperty("color");
    }
  }

  updateFooter();
  Reveal.on('slidechanged', updateFooter);
});
