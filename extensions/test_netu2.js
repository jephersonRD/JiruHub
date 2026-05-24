const https = require('https');

async function testNetu() {
    const url = "https://hqq.tv/player/embed_player.php?vid=Q3h2NEt3dGFHTnhJcmVqMDFuRGZSZz09";
    const userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";
    
    return new Promise((resolve, reject) => {
        https.get(url, {
            headers: {
                "Referer": "https://tioanime.com",
                "User-Agent": userAgent,
                "Accept": "text/html,application/xhtml+xml,*/*"
            }
        }, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                console.log("Status Code:", res.statusCode);
                console.log("Response length:", data.length);
                if (data.length < 500) console.log(data);
                
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
                for (const pattern of patterns) {
                  let m;
                  const re = new RegExp(pattern.source, "g");
                  while ((m = re.exec(data)) !== null) {
                    const u = m[1].replace(/\\/g, "");
                    if (u.startsWith("http")) found.push(u);
                  }
                }
                console.log("Encontrado:", found);
                resolve();
            });
        }).on('error', reject);
    });
}
testNetu();
