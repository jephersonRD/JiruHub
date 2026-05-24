// ==MiruExtension==
// @name         Cuevana3
// @version      v1.0.0
// @author       jephersonRD
// @lang         es
// @license      MIT
// @icon         https://raw.githubusercontent.com/jephersonRD/JiruHub/main/icons/cuevana3.png
// @package      com.jiruhub.cuevana3
// @type         bangumi
// @webSite      https://cuevana3.me
// @description  Ver películas y series en español desde Cuevana3
// ==/MiruExtension==

var extension = {
  latest: function(page) {
    var http = require('http');

    var result = http.get('https://cuevana3.ai/page/' + page);
    var list = [];

    var items = result.matchAll(/<a href="([^"]+)" class="movie-card">[^<]*<img src="([^"]+)"[^>]*>[^<]*<h3>([^<]+)<\/h3>/g);
    for (var item of items) {
      list.push({
        title: item[3],
        url: 'https://cuevana3.ai' + item[1],
        image: item[2]
      });
    }

    return list;
  },

  search: function(kw, page, filter) {
    var http = require('http');

    var result = http.get('https://cuevana3.ai/search?q=' + encodeURIComponent(kw) + '&page=' + page);
    var list = [];

    var items = result.matchAll(/<a href="([^"]+)" class="movie-card">[^<]*<img src="([^"]+)"[^>]*>[^<]*<h3>([^<]+)<\/h3>/g);
    for (var item of items) {
      list.push({
        title: item[3],
        url: 'https://cuevana3.ai' + item[1],
        image: item[2]
      });
    }

    return list;
  },

  detail: function(url) {
    var http = require('http');

    var result = http.get(url);
    var detail = {
      title: '',
      cover: '',
      description: '',
      episodes: []
    };

    var titleMatch = result.match(/<h1 class="title">([^<]+)<\/h1>/);
    if (titleMatch) detail.title = titleMatch[1];

    var coverMatch = result.match(/<img src="([^"]+)" class="poster"/);
    if (coverMatch) detail.cover = coverMatch[1];

    var descMatch = result.match(/<p class="description">([^<]+)<\/p>/);
    if (descMatch) detail.description = descMatch[1];

    var videoMatch = result.match(/<a href="([^"]+)" class="play-btn">/);
    if (videoMatch) {
      detail.episodes.push({
        title: 'Ver',
        url: 'https://cuevana3.ai' + videoMatch[1]
      });
    }

    return detail;
  },

  watch: function(url) {
    var http = require('http');

    var result = http.get(url);
    var video = {
      sources: [],
      subtitles: []
    };

    var videoMatch = result.match(/(?:src|href)="([^"]+\.(?:mp4|m3u8)[^"]*)"/);
    if (videoMatch) {
      video.sources.push({
        url: videoMatch[1],
        type: videoMatch[1].endsWith('.m3u8') ? 'm3u8' : 'mp4'
      });
    }

    return video;
  }
};