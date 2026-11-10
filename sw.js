// Keeps ShiftPurse working offline. The page is fetched fresh when online (so updates show up),
// and falls back to the saved copy when there's no signal.
const CACHE = "shiftpurse-v6";
const SHELL = ["./", "index.html", "manifest.webmanifest", "icons/apple-touch-icon.png", "icons/icon-192.png", "icons/icon-512.png"];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(SHELL)).then(() => self.skipWaiting()));
});
self.addEventListener("activate", e => {
  e.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});
self.addEventListener("fetch", e => {
  const req = e.request, url = new URL(req.url);
  if (req.method !== "GET") return;
  // The Claude API is never cached.
  if (url.hostname === "api.anthropic.com") return;
  // App page: network first, saved copy when offline.
  if (req.mode === "navigate" || (url.origin === location.origin && /\/(index\.html)?$/.test(url.pathname))) {
    e.respondWith(fetch(req.url, { cache: "no-cache", credentials: "same-origin" }).then(res => { const copy = res.clone(); caches.open(CACHE).then(c => c.put("./", copy)); return res; })
      .catch(() => caches.match("./")));
    return;
  }
  // Fonts, icons, the PDF reader and the Claude SDK: saved copy first.
  if (url.origin === location.origin || /fonts\.(googleapis|gstatic)\.com|cdnjs\.cloudflare\.com|cdn\.jsdelivr\.net/.test(url.hostname)) {
    e.respondWith(caches.match(req).then(hit => hit || fetch(req).then(res => {
      if (res.ok || res.type === "opaque") { const copy = res.clone(); caches.open(CACHE).then(c => c.put(req, copy)); }
      return res;
    })));
  }
});
