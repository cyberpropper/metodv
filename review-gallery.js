(() => {
  const grid = document.querySelector('.message-grid');
  if (!grid) return;
  const cards = Array.from(grid.querySelectorAll('.message-card'));
  const more = document.querySelector('.review-more');
  const count = document.querySelector('#review-count');
  const batch = 12;
  let visible = Math.min(batch, cards.length);
  const update = () => {
    cards.forEach((card, index) => { card.hidden = index >= visible; });
    count.textContent = 'Показано ' + visible + ' из ' + cards.length + ' скриншотов';
    more.hidden = visible >= cards.length;
    more.innerHTML = 'Показать ещё ' + Math.min(batch, cards.length - visible) + ' <span aria-hidden="true">↓</span>';
  };
  update();
  more.addEventListener('click', () => {
    const first = visible;
    visible = Math.min(visible + batch, cards.length);
    update();
    cards[first]?.focus();
  });
  const dialog = document.querySelector('.review-lightbox');
  if (!dialog || typeof dialog.showModal !== 'function') return;
  const image = dialog.querySelector('img');
  const prev = dialog.querySelector('.review-prev');
  const next = dialog.querySelector('.review-next');
  const close = dialog.querySelector('.review-close');
  const position = dialog.querySelector('.review-position');
  let selected = 0;
  let opener = null;
  function show(index) {
    selected = Math.max(0, Math.min(index, cards.length - 1));
    image.src = cards[selected].href;
    image.alt = cards[selected].querySelector('img').alt;
    position.textContent = (selected + 1) + ' / ' + cards.length;
    prev.disabled = selected === 0;
    next.disabled = selected === cards.length - 1;
    dialog.querySelector('.review-lightbox__body').scrollTop = 0;
  }
  grid.addEventListener('click', event => {
    const card = event.target.closest('.message-card');
    if (!card || event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;
    event.preventDefault();
    opener = card;
    show(cards.indexOf(card));
    dialog.showModal();
    document.body.classList.add('review-dialog-open');
    close.focus();
  });
  close.addEventListener('click', () => dialog.close());
  prev.addEventListener('click', () => show(selected - 1));
  next.addEventListener('click', () => show(selected + 1));
  dialog.addEventListener('keydown', event => {
    if (event.key === 'ArrowLeft' || event.key === 'ArrowRight') {
      event.preventDefault();
      show(selected + (event.key === 'ArrowRight' ? 1 : -1));
    }
  });
  dialog.addEventListener('click', event => {
    if (event.target !== dialog) return;
    const rect = dialog.getBoundingClientRect();
    if (event.clientX < rect.left || event.clientX > rect.right || event.clientY < rect.top || event.clientY > rect.bottom) dialog.close();
  });
  dialog.addEventListener('close', () => {
    document.body.classList.remove('review-dialog-open');
    opener?.focus({preventScroll: true});
  });
})();

