const fs = require('fs');
const https = require('https');

async function testNetu() {
    const url = "https://hqq.tv/player/embed_player.php?vid=Q3h2NEt3dGFHTnhJcmVqMDFuRGZSZz09";
    const userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";
    
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
            fs.writeFileSync('netu.html', data);
            console.log("Guardado en netu.html");
        });
    });
}
testNetu();
