// ==MiruExtension==
// @name         JiruHub Latino
// @version      v0.3.5
// @author       jephMD
// @lang         es
// @license      MIT
// @icon         https://raw.githubusercontent.com/jephersonRD/JiruHub/main/icons/app.png
// @package      jiruhublatino
// @type         bangumi
// @webSite      https://www.1024terabox.com
// @nsfw         false
// ==/MiruExtension==

const API_URL = "https://raw.githubusercontent.com/jephersonRD/JiruHub/main/extensions/anime_db.json";
const PAGE_SIZE = 20;

// ── Credenciales Terabox embebidas ─────────────────────────────────────────────
// Permiten reproducir sin que el usuario tenga que iniciar sesión.
// La extensión primero intenta las cookies propias del usuario (via getCookie),
// y si no existen usa estas credenciales compartidas automáticamente.
const _TB_BROWSERID  = "f3lSz4SO7FJXE976igfrrFrHKTeWOD9nm1jHBIhZO54VDCwWQotBL4RQBAY=";
const _TB_NDUS       = "YVNSEixteHui_k6a80v4Fx9XOCXArSUsYv88dmW9";
const _TB_CSRF       = "SkgQp-D4uG6lOHvrA8wPon_n";
const _TB_NDUT_FMT   = "E77AFA38699B6BD301C94607771C65ED237DAF8B295D96144AA4804099762763";
const _TB_NDUT_FMV   = "24ec792dd5362ccdf87a18a3d015ca10adbbc65b68138f2368d0a1bdfd707550806968ab2d4d8ccd9c70663762f899afc3265a5022725df5f3609e35fe460da873b949971e174f755da282e922f592e5cacb45d9779dccf5d59c8633ddbe130abe4a26f6d7a4f87e5443f5e5ecc4a0ff";
const _TB_AB_SR      = "1.0.1_MGRlYzc0MzJlNGQ0Y2M3ZDIxYzhkN2FhODQzN2EzYTg0MDkxYjEwNmEwOTc1ZDk3ODdmZjY0NGRlZDZiMDNlNDhkZTc0MTEyNTJiZWQ3NTA0YzU3NDhhZmJjNzg5NGYyYWQzY2E3NWEyYjY2OGY5OTM4NzllNTY4MzNiNzBiYzZkMTAyZTAwZGIwMjMwYmI3NzBkYTQ0ZTA3NDFjOGZlNA==";
// Cookie string listo para usar en cabeceras HTTP
const _TB_COOKIE_STR = [
  "browserid="  + _TB_BROWSERID,
  "ndus="       + _TB_NDUS,
  "csrfToken="  + _TB_CSRF,
  "ndut_fmt="   + _TB_NDUT_FMT,
  "ndut_fmv="   + _TB_NDUT_FMV,
  "ab_sr="      + _TB_AB_SR,
  "lang=en"
].join("; ");
// ──────────────────────────────────────────────────────────────────────────────

function sha1_raw(bytes) {
  var h = [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476, 0xc3d2e1f0];
  var ml = bytes.length * 8;
  var p = bytes.slice();
  p.push(0x80);
  while ((p.length * 8) % 512 !== 448) p.push(0);
  p.push(0, 0, 0, 0);
  p.push((ml >>> 24) & 0xff, (ml >>> 16) & 0xff, (ml >>> 8) & 0xff, ml & 0xff);
  var w = new Array(80);
  for (var bi = 0; bi < p.length; bi += 64) {
    for (var i = 0; i < 16; i++) w[i] = ((p[bi + i * 4] << 24) | (p[bi + i * 4 + 1] << 16) | (p[bi + i * 4 + 2] << 8) | p[bi + i * 4 + 3]) >>> 0;
    for (var i = 16; i < 80; i++) w[i] = ((w[i - 3] ^ w[i - 8] ^ w[i - 14] ^ w[i - 16]) << 1 | (w[i - 3] ^ w[i - 8] ^ w[i - 14] ^ w[i - 16]) >>> 31) >>> 0;
    var a = h[0], B = h[1], c = h[2], d = h[3], e = h[4];
    for (var i = 0; i < 80; i++) {
      var f, k;
      if (i < 20) { f = (B & c) | ((~B) & d); k = 0x5a827999; }
      else if (i < 40) { f = B ^ c ^ d; k = 0x6ed9eba1; }
      else if (i < 60) { f = (B & c) | (B & d) | (c & d); k = 0x8f1bbcdc; }
      else { f = B ^ c ^ d; k = 0xca62c1d6; }
      var temp = ((a << 5) | (a >>> 27)) + f + e + k + (w[i] >>> 0) >>> 0;
      e = d; d = c; c = ((B << 30) | (B >>> 2)) >>> 0; B = a; a = temp;
    }
    h[0] = (h[0] + a) >>> 0; h[1] = (h[1] + B) >>> 0; h[2] = (h[2] + c) >>> 0; h[3] = (h[3] + d) >>> 0; h[4] = (h[4] + e) >>> 0;
  }
  var out = [];
  for (var i = 0; i < 5; i++) { out.push((h[i] >>> 24) & 0xff, (h[i] >>> 16) & 0xff, (h[i] >>> 8) & 0xff, h[i] & 0xff); }
  return out;
}

function hmacSha1Hex(key, msg) {
  var kb = [];
  for (var i = 0; i < key.length; i++) kb.push(key.charCodeAt(i) & 0xff);
  if (kb.length > 64) kb = sha1_raw(kb);
  while (kb.length < 64) kb.push(0);
  var ipad = kb.map(function(b) { return b ^ 0x36; });
  var opad = kb.map(function(b) { return b ^ 0x5c; });
  var mb = [];
  for (var i = 0; i < msg.length; i++) mb.push(msg.charCodeAt(i) & 0xff);
  var inner = sha1_raw(ipad.concat(mb));
  var outer = sha1_raw(opad.concat(inner));
  var hex = "";
  for (var i = 0; i < outer.length; i++) hex += ("0" + outer[i].toString(16)).slice(-2);
  return hex;
}

export default class extends Extension {
  constructor() {
    super();
    this.animeList = null;
  }

  async load() {
    if (this.animeList) return this.animeList;
    try {
      const raw = await this.request("", { headers: { "Miru-Url": API_URL } });
      const data = typeof raw === "string" ? JSON.parse(raw) : raw;
      this.animeList = (data && Array.isArray(data.animes)) ? data.animes : [];
      return this.animeList;
    } catch {
      this.animeList = [];
      return this.animeList;
    }
  }

  async latest(page) {
    const list = await this.load();
    const p = Math.max(1, parseInt(page) || 1);
    const start = (p - 1) * PAGE_SIZE;
    return list.slice(start, start + PAGE_SIZE).map(a => ({
      title: a.title,
      url: a.id,
      cover: a.cover
    }));
  }

  async search(kw, page) {
    const list = await this.load();
    const q = (kw || "").toLowerCase().trim();
    if (!q) return [];
    const filtered = list.filter(a => {
      const title = (a.title || "").toLowerCase();
      const genres = (a.genres || "").toLowerCase();
      const desc = (a.description || "").toLowerCase();
      return title.includes(q) || genres.includes(q) || desc.includes(q);
    });
    const p = Math.max(1, parseInt(page) || 1);
    const start = (p - 1) * PAGE_SIZE;
    return filtered.slice(start, start + PAGE_SIZE).map(a => ({
      title: a.title,
      url: a.id,
      cover: a.cover
    }));
  }

  async detail(id) {
    const list = await this.load();
    const anime = list.find(a => a.id === id);
    if (!anime) return { title: "No encontrado", cover: "", desc: "", episodes: [] };
    let episodesOut = [];
    if (Array.isArray(anime.episodes)) {
      if (anime.episodes.length === 1 && anime.episodes[0].title === "Capitulos") {
        episodesOut = [{
          title: "Capitulos",
          urls: anime.episodes[0].urls.map(ep => ({ name: ep.name, url: ep.url }))
        }];
      } else {
        episodesOut = anime.episodes.map(season => ({
          title: season.title,
          urls: season.urls.map(ep => ({ name: ep.name, url: ep.url }))
        }));
      }
    }
    return { title: anime.title, cover: anime.cover, desc: anime.description || "", episodes: episodesOut };
  }

  // Obtiene las credenciales Terabox:
  // 1) Intenta las cookies propias del usuario desde el cookie jar de la app
  // 2) Si no existen, usa las credenciales embebidas en la extensión
  async _getTeraboxCreds() {
    let cookieStr = null;
    let browserid = _TB_BROWSERID; // fallback embebido

    try {
      const jarCookie = await this.getCookie("browserid");
      if (jarCookie && jarCookie.length > 10) {
        cookieStr = jarCookie;
        // Extraer el valor de browserid del string del cookie jar
        const bidMatch = jarCookie.match(/browserid=([^;]+)/);
        if (bidMatch) browserid = bidMatch[1].trim();
        console.log("[Terabox] Usando cookies del usuario");
      }
    } catch (_) {}

    // Si no hay cookies del usuario, usar las embebidas
    if (!cookieStr) {
      cookieStr = _TB_COOKIE_STR;
      browserid = _TB_BROWSERID;
      console.log("[Terabox] Usando credenciales embebidas");
    }

    return { cookieStr, browserid };
  }

  async watch(url) {
    // URL directa de MP4 — reproducir sin procesamiento extra
    if (url.endsWith(".mp4")) {
      return {
        type: "mp4",
        url: url,
        headers: {
          "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36",
          "Referer": "https://www.1024terabox.com/",
          "Origin": "https://www.1024terabox.com",
          "Cookie": _TB_COOKIE_STR
        },
        subtitles: []
      };
    }

    const surlMatch = url.match(/\/s\/([a-zA-Z0-9_-]+)/);
    const surl = surlMatch ? surlMatch[1] : null;

    if (surl) {
      try {
        const { cookieStr, browserid } = await this._getTeraboxCreds();

        // Paso 1: Metadata del archivo via API de Terabox
        const infoUrl = "/api/shorturlinfo?shorturl=" + surl + "&root=1&app_id=250528&web=1&channel=dubox&clienttype=0";
        const infoRaw = await this.request(infoUrl, {
          headers: {
            "Cookie": cookieStr,
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36",
            "Referer": "https://www.1024terabox.com/",
            "Origin": "https://www.1024terabox.com"
          }
        });
        const infoData = typeof infoRaw === "string" ? JSON.parse(infoRaw) : infoRaw;

        if (infoData && infoData.errno === 0 && Array.isArray(infoData.list) && infoData.list.length > 0) {
          const file    = infoData.list[0];
          const fsId    = file.fs_id;
          const shareid = infoData.shareid;
          const uk      = infoData.uk;

          console.log("[Terabox] Archivo: " + file.server_filename + " | shareid=" + shareid + " uk=" + uk);

          // Paso 2: Generar firma HMAC-SHA1
          const ts        = Math.floor(Date.now() / 1000);
          const signInput = "0dubox" + browserid + ts;
          const hmacKey   = "iuuPc64E4Fhn0rTXEzrnbLph0o5qyEEa";
          const sign      = hmacSha1Hex(hmacKey, signInput);

          // Paso 3: Construir URL de streaming HLS
          const streamUrl = "https://www.1024terabox.com/share/streaming"
            + "?uk="         + uk
            + "&shareid="    + shareid
            + "&type=M3U8_FLV_264_360"
            + "&fid="        + fsId
            + "&sign="       + sign
            + "&timestamp="  + ts
            + "&esl=1&isplayer=1&ehps=1&clienttype=0&app_id=250528&web=1&channel=dubox";

          console.log("[Terabox] URL de stream generada, sign=" + sign.substring(0, 10) + "...");

          return {
            type: "hls",
            url: streamUrl,
            headers: {
              "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36",
              "Referer":    "https://www.1024terabox.com/",
              "Origin":     "https://www.1024terabox.com",
              "Cookie":     cookieStr
            },
            subtitles: []
          };
        } else {
          const errno = infoData ? infoData.errno : "desconocido";
          console.log("[Terabox] API error errno=" + errno);
        }
      } catch (e) {
        console.log("[Terabox] Error: " + String(e));
      }
    }

    // Fallback: devolver URL tal cual con cookies embebidas
    return {
      type: "mp4",
      url: url,
      headers: {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36",
        "Referer":    "https://www.1024terabox.com/",
        "Origin":     "https://www.1024terabox.com",
        "Cookie":     _TB_COOKIE_STR
      },
      subtitles: []
    };
  }
}
