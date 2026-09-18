const documentDialog = document.querySelector('.document-dialog');
const documentImage = documentDialog.querySelector('.document-stage img');
const documentStage = documentDialog.querySelector('.document-stage');
let documentOpener;
document.querySelectorAll('[data-document]').forEach(link => {
  link.addEventListener('click', event => {
    if (event.ctrlKey || event.metaKey || event.shiftKey || event.altKey || typeof documentDialog.showModal !== 'function') return;
    event.preventDefault();
    documentOpener = link;
    const rotation = Number(link.dataset.rotation || 0);
    documentImage.src = link.href;
    documentImage.alt = link.dataset.title;
    documentImage.style.setProperty('--document-rotation', `${rotation}deg`);
    documentStage.classList.toggle('is-quarter-turn', Math.abs(rotation) === 90);
    documentDialog.querySelector('#document-dialog-title').textContent = link.dataset.title;
    documentDialog.querySelector('.document-original').href = link.href;
    documentDialog.showModal();
    document.body.classList.add('document-view-open');
  });
});
documentDialog.querySelector('.document-close').addEventListener('click', () => documentDialog.close());
documentDialog.addEventListener('click', event => {
  const bounds = documentDialog.getBoundingClientRect();
  if (event.target === documentDialog && (event.clientX < bounds.left || event.clientX > bounds.right || event.clientY < bounds.top || event.clientY > bounds.bottom)) documentDialog.close();
});
documentDialog.addEventListener('close', () => {
  document.body.classList.remove('document-view-open');
  documentImage.removeAttribute('src');
  documentOpener?.focus();
});
