// ==JiruHubExtension==
// @name         TioAnime
// @version      v0.1.9
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

  async _get(pathOrUrl, referer) {
    const base = await this._base();
    const url = /^https?:\/\//i.test(pathOrUrl) ? pathOrUrl : base + pathOrUrl;
    return this.request("", {
      headers: {
        "Miru-Url": url,
        "User-Agent": UA,
        "Referer": referer || base + "/",
        "Accept": "text/html,application/xhtml+xml,*/*",
        "Accept-Language": "es-ES,es;q=0.9,en;q=0.8",
      },
    });
  }

  _decode(s) {
    return String(s == null ? "" : s)
      .replace(/<[^>]+>/g, " ")
      .replace(/&amp;/g, "&")
      .replace(/&lt;/g, "<")
      .replace(/&gt;/g, ">")
      .replace(/&quot;/g, '"')
      .replace(/&#0?39;/g, "'")
      .replace(/&apos;/g, "'")
      .replace(/&nbsp;/g, " ")
      .replace(/&#(\d+);/g, (_, d) => String.fromCharCode(parseInt(d, 10)))
      .replace(/\s+/g, " ")
      .trim();
  }

  _abs(base, href) {
    if (!href) return "";
    if (/^https?:\/\//i.test(href)) return href;
    if (href.startsWith("//")) return "https:" + href;
    return base + (href.startsWith("/") ? href : "/" + href);
  }

  // ---------- listados ----------

  _parseList(html, base) {
    const out = [];
    if (!html || typeof html !== "string") return out;
    const blocks = html.match(/<article[^>]*class="[^"]*anime[^"]*"[^>]*>[\s\S]*?<\/article>/g) || [];
    for (const block of blocks) {
      const href = (block.match(/<a[^>]+href="([^"]+)"/) || [])[1];
      if (!href) continue;
      const cover = (block.match(/<img[^>]+src="([^"]+)"/) || [])[1] || "";
      const title = (block.match(/<h3[^>]*>([\s\S]*?)<\/h3>/) || [])[1] || "";
      const url = this._abs(base, href);
      if (!/\/anime\//.test(url)) continue;
      out.push({
        title: this._decode(title) || "Sin título",
        url,
        cover: this._abs(base, cover),
      });
    }
    return out;
  }

  async latest(page) {
    const p = parseInt(page, 10) || 1;
    try {
      const base = await this._base();
      const html = await this._get(`/directorio?p=${p}`);
      return this._parseList(html, base);
    } catch (_) {
      return [];
    }
  }

  async search(kw, page) {
    const p = parseInt(page, 10) || 1;
    try {
      const base = await this._base();
      const html = await this._get(
        `/directorio?q=${encodeURIComponent(kw || "")}&p=${p}`
      );
      return this._parseList(html, base);
    } catch (_) {
      return [];
    }
  }

  // ---------- detalle ----------

  async detail(url) {
    const base = await this._base();
    const empty = { title: "", cover: "", desc: "", episodes: [] };

    let html = "";
    try {
      html = await this._get(url);
    } catch (_) {
      return empty;
    }
    if (!html || typeof html !== "string") return empty;

    const title = this._decode(
      (html.match(/<h1[^>]*class="[^"]*title[^"]*"[^>]*>([\s\S]*?)<\/h1>/) || [])[1] || ""
    );

    const cover =
      (html.match(/<meta[^>]+property="og:image"[^>]+content="([^"]+)"/) || [])[1] ||
      (html.match(/<div class="thumb">[\s\S]*?<img[^>]+src="([^"]+)"/) || [])[1] ||
      "";

    const desc = this._decode(
      (html.match(/<p[^>]*class="[^"]*sinopsis[^"]*"[^>]*>([\s\S]*?)<\/p>/) || [])[1] || ""
    );

    const episodes = [];
    const seen = new Set();

    const pushEp = (epUrl, label) => {
      if (!epUrl || seen.has(epUrl)) return;
      if (!/\/ver\//.test(epUrl)) return;
      seen.add(epUrl);
      const num = parseInt((epUrl.match(/-(\d+)\/?$/) || [])[1], 10);
      episodes.push({
        name: label || (isNaN(num) ? "Episodio" : `Episodio ${num}`),
        url: epUrl,
        _n: isNaN(num) ? 0 : num,
      });
    };

    // 1) Enlaces reales a /ver/ (sin depender de clases CSS)
    const linkRe = /<a[^>]+href="([^"]*\/ver\/[^"#]+)"[^>]*>([\s\S]*?)<\/a>/g;
    let m;
    while ((m = linkRe.exec(html)) !== null) {
      const inner = m[2] || "";
      const label = this._decode((inner.match(/<span[^>]*>([\s\S]*?)<\/span>/) || [])[1] || "");
      pushEp(this._abs(base, m[1]), label);
    }

    // 2) Respaldo: array interno "var episodes = [...]" + slug de anime_info
    if (episodes.length === 0) {
      const slug = (html.match(/var\s+anime_info\s*=\s*\[[^\]]*?,\s*"([^"]+)"/) || [])[1];
      const arr = (html.match(/var\s+episodes\s*=\s*(\[[^\]]*\])/) || [])[1];
      if (slug && arr) {
        try {
          for (const n of JSON.parse(arr)) pushEp(`${base}/ver/${slug}-${n}`, `Episodio ${n}`);
        } catch (_) {}
      }
    }

    episodes.sort((a, b) => a._n - b._n);

    return {
      title: title || "",
      cover: cover || "",
      desc: desc || "",
      episodes: [
        {
          title: "Episodios",
          urls: episodes.map((e) => ({ name: e.name, url: e.url })),
        },
      ],
    };
  }

  // ---------- reproducción ----------

  _refererFor(url) {
    if (!url) return "";
    if (url.includes("yourupload.com")) return "https://www.yourupload.com/";
    if (url.includes("hqq.tv") || url.includes("netu")) return "https://hqq.tv/";
    if (url.includes("ok.ru")) return "https://ok.ru/";
    if (url.includes("streamsb") || url.includes("sbfull") || url.includes("sbplay"))
      return "https://streamsb.com/";
    if (url.includes("fembed") || url.includes("anime789")) return "https://www.fembed.com/";
    if (url.includes("mp4upload")) return "https://www.mp4upload.com/";
    if (url.includes("streamtape")) return "https://streamtape.com/";
    if (url.includes("voe.sx")) return "https://voe.sx/";
    if (url.includes("mega.nz")) return "https://mega.nz/";
    return "https://tioanime.com/";
  }

  async watch(url) {
    try {
      const direct = await this._extractByEmbedUrl(url);
      if (direct && !direct.url.startsWith("error://")) return direct;

      const base = await this._base();
      const page = /^https?:\/\//i.test(url) ? url : base + url;

      if (!/\/ver\//.test(page)) {
        return { type: "hls", url: "error://unsupported-server" };
      }

      const html = await this._get(page);
      if (!html || typeof html !== "string") {
        return { type: "hls", url: "error://extraction-failed" };
      }

      const raw = (html.match(/var\s+videos\s*=\s*(\[[\s\S]*?\]\s*\])\s*;/) || [])[1];
      if (!raw) return { type: "hls", url: "error://no-servers-found" };

      let list = [];
      try {
        list = JSON.parse(raw);
      } catch (_) {
        return { type: "hls", url: "error://no-servers-found" };
      }

      const embedUrls = {};
      const referers = {};
      for (const s of list) {
        if (Array.isArray(s) && s[0] && s[1]) {
          const embed = String(s[1]).replace(/\\\//g, "/");
          embedUrls[s[0]] = embed;
          referers[s[0]] = this._refererFor(embed);
        }
      }

      const preferred = [
        "YourUpload",
        "Streamtape",
        "Mp4Upload",
        "Okru",
        "Netu",
        "HQQ",
        "Voe",
        "Mega",
      ];
      const allNames = [
        ...preferred.filter((n) => embedUrls[n]),
        ...Object.keys(embedUrls).filter((n) => !preferred.includes(n)),
      ];

      let primaryName = null;
      let primaryResult = null;

      for (const name of allNames) {
        if (!embedUrls[name]) continue;
        try {
          const result = await this._extractByEmbedUrl(embedUrls[name]);
          if (result && !result.url.startsWith("error://")) {
            primaryName = name;
            primaryResult = result;
            break;
          }
        } catch (_) {}
      }

      if (!primaryName) {
        return {
          type: "hls",
          url: "error://no-playable-server",
          headers: {
            "X-Servers": JSON.stringify(embedUrls),
            "X-Server-Referers": JSON.stringify(referers),
            "X-Primary-Server": allNames[0] || "",
          },
        };
      }

      return {
        type: "hls",
        url: primaryResult.url,
        headers: {
          ...(primaryResult.headers || {}),
          "Referer": referers[primaryName] || this._refererFor(embedUrls[primaryName]),
          "X-Servers": JSON.stringify(embedUrls),
          "X-Server-Referers": JSON.stringify(referers),
          "X-Primary-Server": primaryName,
        },
      };
    } catch (_) {
      return { type: "hls", url: "error://extraction-failed" };
    }
  }

  async _extractByEmbedUrl(embedUrl) {
    if (!embedUrl || !/^https?:\/\//i.test(embedUrl)) {
      return { type: "hls", url: "error://unsupported-server" };
    }
    if (embedUrl.includes("yourupload.com")) return this._watchYourUpload(embedUrl);
    if (embedUrl.includes("hqq.tv") || embedUrl.includes("netu")) return this._watchNetu(embedUrl);
    if (embedUrl.includes("ok.ru")) return this._watchOkru(embedUrl);
    if (embedUrl.includes("mp4upload.com")) return this._watchMp4Upload(embedUrl);
    if (embedUrl.includes("streamtape.com")) return this._watchStreamtape(embedUrl);
    if (embedUrl.includes("voe.sx")) return this._watchVoe(embedUrl);
    if (embedUrl.includes("mega.nz")) return this._watchMega(embedUrl);
    return { type: "hls", url: "error://unsupported-server" };
  }

  async _watchYourUpload(embedUrl) {
    const html = await this._get(embedUrl, "https://tioanime.com/");
    if (!html || typeof html !== "string" || html.length < 100) {
      return { type: "hls", url: "error://extraction-failed" };
    }
    const m = html.match(/file:\s*['"]?(https?:\/\/[^'"<>\s]+\.mp4[^'"<>\s]*)/);
    if (!m) return { type: "hls", url: "error://extraction-failed" };
    const videoUrl = m[1];
    if (videoUrl.includes("novideo") || videoUrl.includes("/embed/")) {
      return { type: "hls", url: "error://extraction-failed" };
    }
    return {
      type: "hls",
      url: videoUrl,
      headers: { Referer: "https://www.yourupload.com/" },
    };
  }

  async _watchVoe(embedUrl) {
    const html = await this._get(embedUrl, "https://tioanime.com/");
    if (!html || typeof html !== "string" || html.length < 100) {
      return { type: "hls", url: "error://extraction-failed" };
    }

    const candidates = [];
    const push = (u) => {
      if (!u) return;
      const clean = String(u).replace(/\\\//g, "/").replace(/\\/g, "");
      if (!/^https?:\/\//i.test(clean)) return;
      if (clean.includes("test-videos.co.uk")) return;
      if (!/\.(m3u8|mp4)(\?|$)/i.test(clean)) return;
      if (!candidates.includes(clean)) candidates.push(clean);
    };

    const patterns = [
      /"hls"\s*:\s*"([^"]+)"/g,
      /'hls'\s*:\s*'([^']+)'/g,
      /"mp4"\s*:\s*"([^"]+)"/g,
      /'mp4'\s*:\s*'([^']+)'/g,
      /var\s+source\s*=\s*'([^']+)'/g,
      /source\s*:\s*"([^"]+\.(?:m3u8|mp4)[^"]*)"/g,
      /(https?:\/\/[^"'\s<>]+\.m3u8[^"'\s<>]*)/g,
      /(https?:\/\/[^"'\s<>]+\.mp4[^"'\s<>]*)/g,
    ];

    for (const re of patterns) {
      let m;
      const r = new RegExp(re.source, "g");
      while ((m = r.exec(html)) !== null) push(m[1]);
    }

    if (!candidates.length) return { type: "hls", url: "error://extraction-failed" };

    const primary = candidates[0];
    const result = {
      type: "hls",
      url: primary,
      headers: {
        Referer: "https://voe.sx/",
        "User-Agent": UA,
      },
    };
    if (candidates.length > 1) result.headers["X-Voe-Alts"] = JSON.stringify(candidates.slice(1));
    return result;
  }

  async _watchMega(embedUrl) {
    const fileUrl = embedUrl.replace("/embed/", "/file/");
    return {
      type: "hls",
      url: embedUrl,
      headers: {
        Referer: "https://mega.nz/",
        "X-Mega-File": fileUrl,
      },
    };
  }

  async _watchNetu(embedUrl) {
    const mirrors = [embedUrl];
    if (embedUrl.includes("hqq.tv")) mirrors.push(embedUrl.replace("hqq.tv", "hqq.net"));
    if (embedUrl.includes("netu.ac")) mirrors.push(embedUrl.replace("netu.ac", "hqq.tv"));
    if (embedUrl.includes("netu.tv")) mirrors.push(embedUrl.replace("netu.tv", "hqq.tv"));

    for (const mirrorUrl of mirrors) {
      let html;
      try {
        html = await this._get(mirrorUrl, "https://tioanime.com/");
      } catch (_) {
        continue;
      }
      if (!html || typeof html !== "string" || html.length < 100) continue;

      const patterns = [
        /'(https?:\/\/[^']+\.m3u8[^']*)'/g,
        /"(https?:\/\/[^"]+\.m3u8[^"]*)"/g,
        /file:\s*["']?(https?:\/\/[^"'<>\s]+\.m3u8[^"'<>\s]*)/g,
        /source\s*[=:]\s*["']?(https?:\/\/[^"'<>\s]+\.m3u8[^"'<>\s]*)/g,
        /url:\s*["'](https?:\/\/[^"']+\.m3u8[^"']*)/g,
        /'(https?:\/\/[^']+\.mp4[^']*)'/g,
        /"(https?:\/\/[^"]+\.mp4[^"]*)"/g,
      ];

      const found = [];
      const seen = new Set();
      for (const pattern of patterns) {
        let m;
        const re = new RegExp(pattern.source, "g");
        while ((m = re.exec(html)) !== null) {
          const u = m[1].replace(/\\/g, "");
          if (
            !seen.has(u) &&
            !u.includes("undefined") &&
            !u.includes("null") &&
            u.startsWith("http")
          ) {
            seen.add(u);
            found.push(u);
          }
        }
      }
      if (found.length === 0) continue;

      const primary = found[0];
      const cdnReferer =
        primary.includes("cfglobalcdn.com") ||
        primary.includes("netu") ||
        primary.includes("hqq")
          ? "https://hqq.tv/"
          : "https://tioanime.com/";

      const result = {
        type: "hls",
        url: primary,
        headers: {
          "Referer": cdnReferer,
          "Origin": cdnReferer.replace(/\/$/, ""),
          "User-Agent": UA,
        },
      };
      if (found.length > 1) result.headers["X-Netu-Alts"] = JSON.stringify(found.slice(1));
      return result;
    }

    return { type: "hls", url: "error://extraction-failed" };
  }

  async _watchOkru(embedUrl) {
    const html = await this._get(embedUrl, "https://tioanime.com/");
    if (!html || typeof html !== "string" || html.length < 100) {
      return { type: "hls", url: "error://extraction-failed" };
    }
    const m = html.match(/"hlsMasterPlaylistUrl":"([^"]+)"/);
    if (m) {
      return {
        type: "hls",
        url: m[1].replace(/\\/g, ""),
        headers: { Referer: "https://ok.ru/" },
      };
    }
    const mp4 = html.match(/"mp4":\s*\[[\s\S]*?"src":"([^"]+)"/);
    if (mp4) {
      return {
        type: "hls",
        url: mp4[1].replace(/\\/g, ""),
        headers: { Referer: "https://ok.ru/" },
      };
    }
    return { type: "hls", url: "error://extraction-failed" };
  }

  async _watchMp4Upload(embedUrl) {
    const html = await this._get(embedUrl, "https://tioanime.com/");
    if (!html || typeof html !== "string" || html.length < 100) {
      return { type: "hls", url: "error://extraction-failed" };
    }
    const m = html.match(/src:\s*"(https?:\/\/[^"]+\.mp4[^"]*)"/);
    if (!m) return { type: "hls", url: "error://extraction-failed" };
    return {
      type: "hls",
      url: m[1],
      headers: { Referer: "https://www.mp4upload.com/" },
    };
  }

  async _watchStreamtape(embedUrl) {
    const html = await this._get(embedUrl, "https://tioanime.com/");
    if (!html || typeof html !== "string" || html.length < 100) {
      return { type: "hls", url: "error://extraction-failed" };
    }
    const m = html.match(/id="ideoooolink"[^>]*>([^<]+)<\/a>/);
    if (m) {
      return {
        type: "hls",
        url: "https:" + m[1].trim(),
        headers: { Referer: "https://streamtape.com/" },
      };
    }
    const m2 = html.match(/&token=[^&"]+&expires=[^"]+/);
    const base = html.match(/\/\/[^"]*streamtape[^/]+\/get_video\?/);
    if (m2 && base) {
      return {
        type: "hls",
        url: "https:" + base[0] + m2[0],
        headers: { Referer: "https://streamtape.com/" },
      };
    }
    return { type: "hls", url: "error://extraction-failed" };
  }
}
