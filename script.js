const toggle = document.querySelector('.menu-toggle');
// Mini-program links carry fixed main-site attribution directly in HTML.
// They work without JavaScript and do not overwrite the visitor's landing URL.
const stickyAction = document.querySelector('.sticky-action');
const heroSection = document.querySelector('.hero');
const footerSection = document.querySelector('footer');
let scrollScheduled = false;
function updateStickyAction() {
  stickyAction.hidden = heroSection.getBoundingClientRect().bottom > 0 ||
    footerSection.getBoundingClientRect().top < window.innerHeight;
  scrollScheduled = false;
}
window.addEventListener('scroll', () => {
  if (!scrollScheduled) {
    scrollScheduled = true;
    requestAnimationFrame(updateStickyAction);
  }
}, { passive: true });
window.addEventListener('resize', updateStickyAction);
updateStickyAction();

const reviewSlider = document.querySelector('.review-slider');
const previousReview = document.querySelector('[data-slide="prev"]');
const nextReview = document.querySelector('[data-slide="next"]');
function updateReviewControls() {
  previousReview.disabled = reviewSlider.scrollLeft <= 1;
  nextReview.disabled = reviewSlider.scrollLeft + reviewSlider.clientWidth >= reviewSlider.scrollWidth - 2;
}
[previousReview, nextReview].forEach((button, index) => button.addEventListener('click', () => {
  const card = reviewSlider.querySelector('article');
  reviewSlider.scrollBy({ left: (index ? 1 : -1) * (card.getBoundingClientRect().width + 18),
    behavior: window.matchMedia('(prefers-reduced-motion: reduce)').matches ? 'instant' : 'smooth' });
}));
reviewSlider.addEventListener('scroll', updateReviewControls, { passive: true });
window.addEventListener('resize', updateReviewControls);
updateReviewControls();
const header = document.querySelector('.site-header');

toggle.addEventListener('click', () => {
  const open = header.classList.toggle('menu-open');
  toggle.setAttribute('aria-expanded', String(open));
  toggle.setAttribute('aria-label', open ? 'Закрыть меню' : 'Открыть меню');
  document.body.style.overflow = open ? 'hidden' : '';
  document.body.classList.toggle('menu-is-open', open);
});

document.querySelectorAll('.desktop-nav a').forEach(link => link.addEventListener('click', () => {
  header.classList.remove('menu-open');
  toggle.setAttribute('aria-expanded', 'false');
  document.body.style.overflow = '';
  document.body.classList.remove('menu-is-open');
}));

const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('is-visible');
      observer.unobserve(entry.target);
    }
  });
}, { threshold: 0.12 });

document.querySelectorAll('.reveal').forEach(element => observer.observe(element));

document.querySelectorAll('.question-card').forEach(card => {
  card.addEventListener('toggle', () => {
    if (!card.open) return;
    document.querySelectorAll('.question-card[open]').forEach(openCard => {
      if (openCard !== card) openCard.removeAttribute('open');
    });
  });
});
