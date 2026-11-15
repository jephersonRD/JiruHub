// ==JiruHubExtension==
// @name         TioAnime
// @version      v0.2.0
// @author       JiruHub
// @lang         es
// @license      MIT
// @icon         https://tioanime.com/favicon.ico
// @package      tioanime
// @type         bangumi
// @webSite      https://tioanime.com
// @description  Anime en español Latino vía TioAnime (scraping directo)
// ==/JiruHubExtension==

const UA =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36";

// Orden de preferencia. Primero lo que entrega m3u8, luego mp4, Mega al final.
const PRIORITY = [
  /voe/i,
  /ok\.?ru/i,
  /filemoon|filemoon\.sx/i,
  /streamtape/i,
  /yourupload/i,
  /mp4upload/i,
  /dood/i,
  /mixdrop/i,
  /hqq|netu/i,
  /mega/i,
];

export default class extends Extension {
  async load() {
    this.registerSetting({
      title: "Dominio de TioAnime",
      key: "tioanime",
      type: "input",
      description: "Dominio base del sitio (cámbialo si cambian de dominio)",
      defaultValue: "https://tioanime.com",
    });
  }

  async createFilter() {
    return {};
  }

  // ---------- utilidades ----------

  async _base() {
    let b = await this.getSetting("tioanime");
    b = String(b || "").trim();
    if (!b) b = "https://tioanime.com";
    if (!/^https?:\/\//i.test(b)) b = "https://" + b;
    return b.replace(/\/+$/, "");
  }

  _abs(url, base) {
    const u = String(url || "").trim();
    if (!u) return "";
    if (/^https?:\/\//i.test(u)) return u;
    if (u.startsWith("//")) return "https:" + u;
    if (u.startsWith("/")) return base + u;
    return base + "/" + u;
  }

  async _get(url, referer) {
    const headers = {
      "Miru-Url": url,
      "User-Agent": UA,
      "Accept":
        "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,*/*;q=0.8",
      "Accept-Language": "es-ES,es;q=0.9,en;q=0.8",
    };
    if (referer) headers["Referer"] = referer;
    try {
      return await this.request("", { headers });
    } catch (_) {
      return "";
    }
  }

  _refererFor(url) {
    try {
      const u = new URL(url);
      if (/mega\.nz$/.test(u.hostname)) return "https://mega.nz/";
      return u.origin + "/";
    } catch (_) {
      return "https://tioanime.com/";
    }
  }

  _err(tag, extra) {
    return { type: "hls", url: "error://" + tag, headers: extra || {} };
  }

  // ---------- listados ----------

  async latest(page) {
    const base = await this._base();
    const p = Number(page) > 0 ? Number(page) : 1;
    const html = await this._get(base + "/directorio?p=" + p, base + "/directorio");
    return this._parseList(html, base);
  }

  async search(kw, page) {
    const base = await this._base();
    const p = Number(page) > 0 ? Number(page) : 1;
    const q = encodeURIComponent(String(kw || "").trim());
    const html = await this._get(
      base + "/directorio?q=" + q + "&p=" + p,
      base + "/directorio"
    );
    return this._parseList(html, base);
  }

  async trending(page) {
    return this.latest(page);
  }

  _parseList(html, base) {
    const out = [];
    if (!html || typeof html !== "string") return out;
    const seen = new Set();
    const blocks =
      html.match(/<article[^>]*class="[^"]*anime[^"]*"[^>]*>[\s\S]*?<\/article>/gi) || [];
    for (const block of blocks) {
      const href =
        (block.match(/href="([^"]*\/anime\/[^"]+)"/i) || [])[1] ||
        (block.match(/href="([^"]+)"/i) || [])[1];
      const url = this._abs(href, base);
      if (!url || !/\/anime\//i.test(url) || seen.has(url)) continue;
      seen.add(url);

      const titleRaw =
        (block.match(/<h3[^>]*>([\s\S]*?)<\/h3>/i) || [])[1] ||
        (block.match(/<a[^>]*title="([^"]+)"/i) || [])[1] ||
        "";
      const title = this._clean(titleRaw);
      if (!title) continue;

      const coverRaw =
        (block.match(/<img[^>]+src="([^"]+)"/i) || [])[1] ||
        (block.match(/<img[^>]+data-src="([^"]+)"/i) || [])[1] ||
        "";
      const cover = this._abs(coverRaw, base);

      const eps = (block.match(/<span[^>]*class="[^"]*episodes[^"]*"[^>]*>([\s\S]*?)<\/span>/i) || [])[1];
      const type = (block.match(/<span[^>]*class="[^"]*type[^"]*"[^>]*>([\s\S]*?)<\/span>/i) || [])[1];

      out.push({
        title,
        url,
        cover,
        indicator: eps ? this._clean(eps) : "",
        subIndicator: type ? this._clean(type) : "",
      });
    }
    return out;
  }

  _clean(s) {
    return String(s || "")
      .replace(/<[^>]*>/g, " ")
      .replace(/&amp;/g, "&")
      .replace(/&quot;/g, '"')
      .replace(/&#39;/g, "'")
      .replace(/&nbsp;/g, " ")
      .replace(/\s+/g, " ")
      .trim();
  }

  // ---------- detalle ----------

  async detail(url) {
    const base = await this._base();
    const pageUrl = this._abs(url, base);
    const html = await this._get(pageUrl, base + "/directorio");
    if (!html || typeof html !== "string") {
      return { title: "", url: pageUrl, episodes: [] };
    }

    const titleRaw =
      (html.match(/<h1[^>]*class="[^"]*title[^"]*"[^>]*>([\s\S]*?)<\/h1>/i) || [])[1] ||
      (html.match(/<meta[^>]+property="og:title"[^>]+content="([^"]+)"/i) || [])[1] ||
      (html.match(/<title[^>]*>([\s\S]*?)<\/title>/i) || [])[1] ||
      "";
    const title = this._clean(titleRaw).replace(/\s*-\s*TioAnime\s*$/i, "");

    const coverRaw =
      (html.match(/<meta[^>]+property="og:image"[^>]+content="([^"]+)"/i) || [])[1] ||
      (html.match(/<img[^>]+class="[^"]*thumb[^"]*"[^>]+src="([^"]+)"/i) || [])[1] ||
      "";
    const cover = this._abs(coverRaw, base);

    const descRaw =
      (html.match(/<p[^>]*class="[^"]*sinopsis[^"]*"[^>]*>([\s\S]*?)<\/p>/i) || [])[1] || "";
    const description = this._clean(descRaw);

    const statusRaw =
      (html.match(/<span[^>]*class="[^"]*status[^"]*"[^>]*>([\s\S]*?)<\/span>/i) || [])[1] || "";
    const status = this._clean(statusRaw);

    const genres = [];
    const genreRe = /<a[^>]+href="[^"]*\/genero\/[^"]*"[^>]*>([\s\S]*?)<\/a>/gi;
    let gm;
    while ((gm = genreRe.exec(html)) !== null) {
      const g = this._clean(gm[1]);
      if (g && !genres.includes(g)) genres.push(g);
    }

    // Episodios: cualquier enlace /ver/ del documento.
    const episodes = [];
    const seen = new Set();
    const linkRe = /<a[^>]+href="([^"]*\/ver\/[^"]+)"[^>]*>([\s\S]*?)<\/a>/gi;
    let m;
    while ((m = linkRe.exec(html)) !== null) {
      const epUrl = this._abs(m[1], base);
      if (!epUrl || seen.has(epUrl)) continue;
      seen.add(epUrl);
      const num = Number((epUrl.match(/-(\d+)(?:[\/?#]|$)/) || [])[1] || 0);
      const label = this._clean(m[2]) || (num ? "Episodio " + num : "Episodio");
      episodes.push({ number: num, title: label, url: epUrl });
    }

    // Respaldo: var anime_info + var episodes del propio HTML.
    if (!episodes.length) {
      const slug = (html.match(/var\s+anime_info\s*=\s*\[[^\]]*?,\s*"([^"]+)"/i) || [])[1];
      const arrRaw = (html.match(/var\s+episodes\s*=\s*(\[[^\]]*\])/i) || [])[1];
      if (slug && arrRaw) {
        try {
          const nums = JSON.parse(arrRaw);
          if (Array.isArray(nums)) {
            for (const n of nums) {
              const epUrl = base + "/ver/" + slug + "-" + n;
              if (seen.has(epUrl)) continue;
              seen.add(epUrl);
              episodes.push({ number: Number(n) || 0, title: "Episodio " + n, url: epUrl });
            }
          }
        } catch (_) {}
      }
    }

    episodes.sort((a, b) => a.number - b.number);

    return { title, cover, description, status, genres, url: pageUrl, episodes };
  }

  // ---------- reproducción ----------

  async watch(url) {
    const base = await this._base();
    const pageUrl = this._abs(url, base);
    const html = await this._get(pageUrl, base + "/directorio");
    if (!html || typeof html !== "string") return this._err("watch-page");

    const servers = this._parseServers(html);
    if (!servers.length) return this._err("no-servers");

    const embedUrls = {};
    const referers = {};
    for (const s of servers) {
      if (!s.name || !s.url) continue;
      if (embedUrls[s.name]) continue;
      embedUrls[s.name] = s.url;
      referers[s.name] = this._refererFor(s.url);
    }

    const names = this._orderNames(Object.keys(embedUrls));
    const baseHeaders = {
      "X-Servers": JSON.stringify(embedUrls),
      "X-Server-Referers": JSON.stringify(referers),
    };

    for (const name of names) {
      const embedUrl = embedUrls[name];
      if (!embedUrl) continue;
      let result = null;
      try {
        result = await this._extract(name, embedUrl);
      } catch (_) {
        result = null;
      }
      if (result && result.url && !String(result.url).startsWith("error://")) {
        return {
          type: result.type || "hls",
          url: result.url,
          headers: {
            ...(result.headers || {}),
            "Referer": referers[name] || this._refererFor(embedUrl),
            "X-Primary-Server": name,
            ...baseHeaders,
          },
        };
      }
    }

    // Nada extraíble: devolvemos la lista para que se elija a mano.
    return {
      type: "hls",
      url: "error://no-playable-server",
      headers: { ...baseHeaders, "X-Primary-Server": names[0] || "" },
    };
  }

  _orderNames(names) {
    const used = new Set();
    const ordered = [];
    for (const re of PRIORITY) {
      for (const n of names) {
        if (used.has(n)) continue;
        if (re.test(n) || re.test(this._hostOf(n))) {
          used.add(n);
          ordered.push(n);
        }
      }
    }
    for (const n of names) if (!used.has(n)) ordered.push(n);
    return ordered;
  }

  _hostOf(name) {
    return String(name || "");
  }

  _parseServers(html) {
    const out = [];
    const arr = (html.match(/var\s+videos\s*=\s*(\[[\s\S]*?\])\s*;/i) || [])[1];
    if (!arr) return out;
    const rowRe = /\[\s*"([^"]+)"\s*,\s*"([^"]+)"\s*(?:,\s*"?[^",\]]*"?\s*,\s*"?[^",\]]*"?\s*)?\]/g;
    let m;
    while ((m = rowRe.exec(arr)) !== null) {
      const name = this._clean(m[1]);
      const url = m[2].trim();
      if (!name || !url) continue;
      if (out.some((s) => s.name === name)) continue;
      out.push({ name, url });
    }
    return out;
  }

  async _extract(name, embedUrl) {
    const n = String(name || "").toLowerCase();
    const u = String(embedUrl || "").toLowerCase();
    if (u.includes("voe") || n.includes("voe")) return this._watchVoe(embedUrl);
    if (u.includes("ok.ru") || u.includes("okru") || n.includes("okru")) return this._watchOkru(embedUrl);
    if (u.includes("filemoon") || n.includes("filemoon")) return this._watchFilemoon(embedUrl);
    if (u.includes("streamtape") || n.includes("streamtape")) return this._watchStreamtape(embedUrl);
    if (u.includes("yourupload") || n.includes("yourupload")) return this._watchYourUpload(embedUrl);
    if (u.includes("mp4upload") || n.includes("mp4upload")) return this._watchMp4Upload(embedUrl);
    if (u.includes("dood") || n.includes("dood")) return this._watchDood(embedUrl);
    if (u.includes("hqq") || u.includes("netu") || n.includes("netu") || n.includes("hqq"))
      return this._watchNetu(embedUrl);
    if (u.includes("mega.nz") || n.includes("mega")) return this._watchMega(embedUrl);
    return this._watchGeneric(embedUrl, this._refererFor(embedUrl));
  }

  _fromHtml(html, referer) {
    if (!html || typeof html !== "string") return null;
    const hls =
      html.match(/["']([^"']+\.m3u8[^"']*)["']/i) ||
      html.match(/https?:\/\/[^"'\s<>]+\.m3u8[^"'\s<>]*/i);
    if (hls) {
      const url = hls[1] || hls[0];
      if (/^https?:\/\//i.test(url)) {
        return { type: "hls", url, headers: { "Referer": referer, "Origin": this._origin(referer) } };
      }
    }
    const mp4 =
      html.match(/["']([^"']+\.mp4[^"']*)["']/i) ||
      html.match(/https?:\/\/[^"'\s<>]+\.mp4[^"'\s<>]*/i);
    if (mp4) {
      const url = mp4[1] || mp4[0];
      if (/^https?:\/\//i.test(url)) {
        return { type: "video", url, headers: { "Referer": referer, "Origin": this._origin(referer) } };
      }
    }
    return null;
  }

  _origin(url) {
    try {
      return new URL(url).origin + "/";
    } catch (_) {
      return "";
    }
  }

  async _watchVoe(embedUrl) {
    let html = await this._get(embedUrl, "https://voe.sx/");
    if (!html) return this._err("voe");
    // Voe a veces redirige a /e/<id> por JS.
    const redir = (html.match(/window\.location\.href\s*=\s*['"]([^'"]+)['"]/i) || [])[1];
    if (redir && !/\.m3u8|\.mp4/i.test(redir)) {
      const next = this._abs(redir, "https://voe.sx");
      html = await this._get(next, embedUrl);
    }
    return (
      this._fromHtml(html, embedUrl) ||
      this._err("voe")
    );
  }

  async _watchOkru(embedUrl) {
    const html = await this._get(embedUrl, "https://ok.ru/");
    if (!html) return this._err("okru");
    const hls =
      html.match(/hlsMasterPlaylistUrl\\?"\s*:\s*\\?"([^"\\]+)/i) ||
      html.match(/hlsMasterPlaylistUrl"\s*:\s*"([^"]+)/i);
    if (hls && hls[1]) {
      const url = hls[1].replace(/\\\//g, "/");
      return { type: "hls", url, headers: { "Referer": embedUrl, "Origin": "https://ok.ru/" } };
    }
    const mp4 =
      html.match(/\\?"url\\?"\s*:\s*\\?"(https:[^"\\]+\.mp4[^"\\]*)/i) ||
      html.match(/"url"\s*:\s*"(https:[^"]+\.mp4[^"]*)"/i);
    if (mp4 && mp4[1]) {
      const url = mp4[1].replace(/\\\//g, "/");
      return { type: "video", url, headers: { "Referer": embedUrl, "Origin": "https://ok.ru/" } };
    }
    return this._err("okru");
  }

  async _watchFilemoon(embedUrl) {
    const html = await this._get(embedUrl, this._refererFor(embedUrl));
    const m =
      (html && html.match(/file\s*:\s*["']([^"']+)["']/i)) ||
      (html && html.match(/sources\s*:\s*\[\s*\{\s*file\s*:\s*["']([^"']+)["']/i));
    if (!m || !m[1]) return this._err("filemoon");
    const url = m[1].replace(/\\\//g, "/");
    return {
      type: /\.m3u8/i.test(url) ? "hls" : "video",
      url,
      headers: { "Referer": embedUrl, "Origin": this._origin(embedUrl) },
    };
  }

  async _watchStreamtape(embedUrl) {
    const html = await this._get(embedUrl, "https://streamtape.com/");
    if (!html) return this._err("streamtape");
    let link =
      (html.match(/id=["']ideoolink["'][^>]*>([^<]+)</i) || [])[1] ||
      (html.match(/id=["']robotlink["'][^>]*>([^<]+)</i) || [])[1];
    if (!link) return this._err("streamtape");
    link = link.replace(/^\s+|\s+$/g, "");
    if (link.includes("' + '")) {
      const parts = link.split("' + '").map((p) => p.replace(/['"]/g, ""));
      link = parts.join("");
    }
    if (link.startsWith("//")) link = "https:" + link;
    if (!/^https?:\/\//i.test(link)) link = "https:" + link;
    return {
      type: "video",
      url: link,
      headers: { "Referer": embedUrl, "Origin": "https://streamtape.com/" },
    };
  }

  async _watchYourUpload(embedUrl) {
    const html = await this._get(embedUrl, "https://www.yourupload.com/");
    if (!html) return this._err("yourupload");
    const m =
      (html.match(/file\s*:\s*["']?(https?:\/\/[^'"<>\s]+\.mp4[^'"<>\s]*)/i) ||
      (html.match(/["'](https?:\/\/[^"'<>\s]+\.mp4[^"'<>\s]*)/i)));
    const url = m && (m[1] || m[0]);
    if (!url) return this._err("yourupload");
    return {
      type: "video",
      url,
      headers: { "Referer": embedUrl, "Origin": "https://www.yourupload.com/" },
    };
  }

  async _watchMp4Upload(embedUrl) {
    const html = await this._get(embedUrl, "https://www.mp4upload.com/");
    if (!html) return this._err("mp4upload");
    const m =
      (html.match(/src\s*:\s*["'](https?:\/\/[^"']+\.mp4[^"']*)/i) ||
      (html.match(/["'](https?:\/\/[^"']+\.mp4[^"']*)/i)));
    const url = m && (m[1] || m[0]);
    if (!url) return this._err("mp4upload");
    return {
      type: "video",
      url,
      headers: { "Referer": embedUrl, "Origin": "https://www.mp4upload.com/" },
    };
  }

  async _watchDood(embedUrl) {
    const html = await this._get(embedUrl, this._refererFor(embedUrl));
    if (!html) return this._err("dood");
    const pass = (html.match(/pass_md5\/([^"']+)/i) || [])[1];
    const token = (html.match(/token=([^"'&]+)/i) || [])[1];
    if (!pass) return this._fromHtml(html, embedUrl) || this._err("dood");
    const host = this._origin(embedUrl).replace(/\/$/, "");
    const tokenPath = pass.split("/").slice(0, -1).join("/");
    const body = await this._get(host + "/pass_md5/" + pass, embedUrl);
    if (!body || typeof body !== "string") return this._err("dood");
    const rnd = Math.random().toString(36).slice(2, 12);
    const url = body.trim() + rnd + (token ? "?token=" + token + "&" : "?") + "ip=0.0.0.0&token=" + (token || tokenPath);
    return {
      type: "video",
      url,
      headers: { "Referer": embedUrl, "Origin": host + "/" },
    };
  }

  async _watchNetu(embedUrl) {
    const vid = (embedUrl.match(/[?&]vid=([A-Za-z0-9]+)/) || [])[1];
    let html = "";
    try {
      html = await this.request("", {
        method: "POST",
        headers: {
          "Miru-Url": "https://hqq.tv/player/embed_player.php?vid=" + (vid || ""),
          "Content-Type": "application/x-www-form-urlencoded",
          "User-Agent": UA,
          "Referer": embedUrl,
          "Origin": "https://hqq.tv",
        },
        body: "vid=" + (vid || "") + "&ads=1&b=1",
      });
    } catch (_) {}
    if (!html) html = await this._get(embedUrl, "https://hqq.tv/");
    const m =
      (html && html.match(/file\s*:\s*["']([^"']+\.m3u8[^"']*)/i)) ||
      (html && html.match(/file\s*:\s*["']([^"']+)["']/i));
    if (!m || !m[1]) return this._err("netu");
    const url = m[1].replace(/\\\//g, "/");
    return {
      type: /\.m3u8/i.test(url) ? "hls" : "video",
      url,
      headers: { "Referer": embedUrl, "Origin": "https://hqq.tv" },
    };
  }

  // Mega: embed HTML cifrado. Sigue al último recurso, pero si otro servidor
  // responde antes, esto ni se ejecuta.
  async _watchMega(embedUrl) {
    const html = await this._get(embedUrl, "https://mega.nz/");
    if (!html) return this._err("mega");
    // Si por casualidad el embed ya trae una pista directa, la usamos.
    const direct = this._fromHtml(html, embedUrl);
    if (direct) return direct;
    // Si no, intentamos el endpoint público de metadatos.
    const id = (embedUrl.match(/\/embed\/(?:file\/)?([^!\/]+)/) || [])[1];
    if (id) {
      try {
        const api = "https://g.api.mega.co.nz/cs?id=0&n=" + encodeURIComponent(id);
        const json = await this.request("", {
          headers: { "Miru-Url": api, "User-Agent": UA, "Referer": "https://mega.nz/" },
        });
        const text = typeof json === "string" ? json : JSON.stringify(json || "");
        const g = (text.match(/"g"\s*:\s*"([^"]+)"/) || [])[1];
        if (g && /^https?:\/\//i.test(g)) {
          return { type: "video", url: g, headers: { "Referer": "https://mega.nz/" } };
        }
      } catch (_) {}
    }
    return this._err("mega");
  }

  async _watchGeneric(embedUrl, referer) {
    const html = await this._get(embedUrl, referer);
    if (!html) return this._err("generic");
    const direct = this._fromHtml(html, embedUrl);
    if (direct) return direct;
    // Un nivel de iframe anidado.
    const iframe =
      (html.match(/<iframe[^>]+src=["']([^"']+)["']/i) || [])[1] ||
      (html.match(/<embed[^>]+src=["']([^"']+)["']/i) || [])[1];
    if (iframe) {
      const next = this._abs(iframe, this._origin(embedUrl));
      if (next && next !== embedUrl) {
        const inner = await this._get(next, embedUrl);
        const found = this._fromHtml(inner, next);
        if (found) return found;
      }
    }
    return this._err("generic");
  }
}
