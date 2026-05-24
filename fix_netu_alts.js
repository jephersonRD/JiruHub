const fs = require('fs');

function fixNetu(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  
  // Buscar el bloque donde crea el result en _watchNetu
  const targetCode = `        // Inyectar alternativas si hay más de una
        if (found.length > 1) {
          result.headers["X-Netu-Alts"] = JSON.stringify(found.slice(1));
        }
        return result;`;
        
  const replaceCode = `        // Generar alternativas de host para bypassear bloqueo ISP
        const alts = new Set(found.slice(1));
        const path = new URL(primary).pathname;
        const search = new URL(primary).search;
        
        // Dominios espejos conocidos de Netu/HQQ
        const cdnMirrors = [
          "hqq.tv", "hqq.to", "netu.ac", "netu.to", "netu.tv", 
          "wvw.hqq.tv", "v.hqq.tv", "4fw4gd.cfglobalcdn.com"
        ];
        
        for (const mirror of cdnMirrors) {
          alts.add("https://" + mirror + path + search);
        }
        
        // Inyectar alternativas
        const altsArr = Array.from(alts).filter(u => u !== primary);
        if (altsArr.length > 0) {
          result.headers["X-Netu-Alts"] = JSON.stringify(altsArr);
        }
        return result;`;
        
  if (content.includes(targetCode)) {
    content = content.replace(targetCode, replaceCode);
    fs.writeFileSync(filePath, content);
    console.log("Fixed: " + filePath);
  } else {
    console.log("Target code not found in: " + filePath);
  }
}

fixNetu('/home/jeph/Documents/miru-app/extensions/animeflv.js');
fixNetu('/home/jeph/Documents/miru-app/extensions/tioanime.js');
fixNetu('/home/jeph/Documents/jiruhub/extensions/anime.flv.js');
fixNetu('/home/jeph/Documents/miru-app/_jiruhub_fix/extensions/tioanime.js');
