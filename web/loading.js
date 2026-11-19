const visionLoadingMessages = {"en": {"loadingApp": "Opening Vision Music…", "slowConnection": "This is taking longer than usual. Check your connection.", "startupError": "Could not start Vision Music.", "retry": "Retry"}, "om": {"loadingApp": "Vision Music banamaa jira…", "slowConnection": "Kun yeroo dheeraa fudhachaa jira. Interneetii kee ilaali.", "startupError": "Vision Music jalqabuun hin danda'amne.", "retry": "Irra deebi'ii yaali"}, "am": {"loadingApp": "Vision Music እየተከፈተ ነው…", "slowConnection": "ይህ ከተለመደው በላይ ጊዜ እየወሰደ ነው። ግንኙነትዎን ያረጋግጡ።", "startupError": "Vision Musicን ማስጀመር አልተቻለም።", "retry": "እንደገና ይሞክሩ"}, "ar": {"loadingApp": "جارٍ فتح Vision Music…", "slowConnection": "يستغرق هذا وقتًا أطول من المعتاد. تحقق من اتصالك.", "startupError": "تعذر بدء Vision Music.", "retry": "إعادة المحاولة"}, "fr": {"loadingApp": "Ouverture de Vision Music…", "slowConnection": "Cela prend plus de temps que prévu. Vérifiez votre connexion.", "startupError": "Impossible de démarrer Vision Music.", "retry": "Réessayer"}, "es": {"loadingApp": "Abriendo Vision Music…", "slowConnection": "Esto está tardando más de lo habitual. Comprueba tu conexión.", "startupError": "No se pudo iniciar Vision Music.", "retry": "Reintentar"}};
(() => {
  let locale = (navigator.language || 'en').split('-')[0];
  try {
    const saved = JSON.parse(localStorage.getItem('flutter.localeCode'));
    if (visionLoadingMessages[saved]) locale = saved;
  } catch (_) {}
  const strings = visionLoadingMessages[locale] || visionLoadingMessages.en;
  document.documentElement.lang = visionLoadingMessages[locale] ? locale : 'en';
  // Flutter controls app direction and semantic coordinates itself.
  // Scope RTL to the HTML loader to keep Arabic accessibility targets on-screen.
  document.getElementById('app-loading').dir = locale === 'ar' ? 'rtl' : 'ltr';
  const status = document.getElementById('loading-status');
  const retry = document.getElementById('loading-retry');
  status.textContent = strings.loadingApp;
  retry.textContent = strings.retry;
  retry.addEventListener('click', () => location.reload());
  const slow = setTimeout(() => {
    status.textContent = strings.slowConnection;
    retry.hidden = false;
  }, 20000);
  window.visionLoadingDone = () => {
    clearTimeout(slow);
    document.getElementById('app-loading')?.remove();
  };
  window.visionLoadingFailed = () => {
    clearTimeout(slow);
    status.textContent = strings.startupError + ' ' + strings.slowConnection;
    retry.hidden = false;
  };
  window.addEventListener('flutter-first-frame', window.visionLoadingDone, {once: true});
})();
