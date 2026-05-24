import { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import Navbar from '../components/Navbar';

export default function Developers() {
  const [followers, setFollowers] = useState<number | null>(null);
  const [avatar, setAvatar] = useState('');

  useEffect(() => {
    fetch('https://api.github.com/users/jephersonRD')
      .then(r => r.json())
      .then(d => {
        setFollowers(d.followers);
        setAvatar(d.avatar_url);
      })
      .catch(() => {});
  }, []);

  const socials = [
    { name: 'TikTok', user: '@jephMD', url: 'https://www.tiktok.com/@jephMD', icon: 'https://img.icons8.com/fluency/96/tiktok.png' },
    { name: 'YouTube', user: '@jephmd', url: 'https://www.youtube.com/@jephmd', icon: 'https://img.icons8.com/fluency/96/youtube-play.png' },
    { name: 'Twitter / X', user: '@JephMD', url: 'https://x.com/JephMD', icon: 'https://img.icons8.com/fluency/96/twitterx.png' },
    { name: 'Reddit', user: 'u/Jeph-MD', url: 'https://www.reddit.com/user/Jeph-MD/', icon: 'https://img.icons8.com/fluency/96/reddit.png' },
    { name: 'Instagram', user: '@jepherson_medina', url: 'https://www.instagram.com/jepherson_medina/', icon: 'https://img.icons8.com/fluency/96/instagram-new.png' },
  ];

  const projects = [
    {
      name: 'Maquina-V5',
      desc: 'Gaming en la nube con GPU — gratis. NVIDIA Tesla T4 via Google Colab, Steam, Epic y más.',
      url: 'https://github.com/jephersonRD/Maquina-V5',
      stars: 'https://img.shields.io/github/stars/jephersonRD/Maquina-V5?style=flat-square&color=c0294a',
      forks: 'https://img.shields.io/github/forks/jephersonRD/Maquina-V5?style=flat-square&color=555',
    },
    {
      name: 'PC-Free',
      desc: 'Windows 10 en el navegador sin instalación. GitHub Codespaces + Docker, deploy en 5 min.',
      url: 'https://github.com/jephersonRD/PC-Free',
      stars: 'https://img.shields.io/github/stars/jephersonRD/PC-Free?style=flat-square&color=c0294a',
      forks: 'https://img.shields.io/github/forks/jephersonRD/PC-Free?style=flat-square&color=555',
    },
    {
      name: 'Foxix Terminal',
      desc: 'Emulador de terminal GPU-acelerado en Rust. OpenGL 4.6, 12 MB RAM, 20ms startup. Wayland/Hyprland.',
      url: 'https://github.com/jephersonRD/foxix-terminal',
      stars: 'https://img.shields.io/github/stars/jephersonRD/foxix-terminal?style=flat-square&color=c0294a',
      forks: 'https://img.shields.io/github/forks/jephersonRD/foxix-terminal?style=flat-square&color=555',
    },
    {
      name: 'FlinChop',
      desc: 'Editor de video e imágenes con IA — gratis. Alternativa open source a CapCut y Filmora. 4K sin marca de agua.',
      url: 'https://github.com/jephersonRD/FlinChop',
      stars: 'https://img.shields.io/github/stars/jephersonRD/FlinChop?style=flat-square&color=c0294a',
      forks: 'https://img.shields.io/github/forks/jephersonRD/FlinChop?style=flat-square&color=555',
    },
    {
      name: 'PC-Cloud-V2',
      desc: 'PC en la nube v2 — mejoras sobre PC-Free. Acceso remoto desde cualquier dispositivo, streaming de alta calidad.',
      url: 'https://github.com/jephersonRD/PC-Cloud-V2',
      stars: 'https://img.shields.io/github/stars/jephersonRD/PC-Cloud-V2?style=flat-square&color=c0294a',
      forks: 'https://img.shields.io/github/forks/jephersonRD/PC-Cloud-V2?style=flat-square&color=555',
    },
    {
      name: 'ModerLauncher',
      desc: 'Launcher seguro para Minecraft Java Edition. Cuentas premium y offline, Material Design, Win/Linux.',
      url: 'https://github.com/jephersonRD/ModerLauncher',
      stars: 'https://img.shields.io/github/stars/jephersonRD/ModerLauncher?style=flat-square&color=c0294a',
      forks: 'https://img.shields.io/github/forks/jephersonRD/ModerLauncher?style=flat-square&color=555',
    },
  ];

  const techStack = [
    { label: 'Frontend', icons: ['react', 'js', 'html', 'css', 'bootstrap'] },
    { label: 'Backend', icons: ['python', 'django', 'bash', 'mysql', 'rust'] },
    { label: 'Tools', icons: ['git', 'linux', 'docker', 'vscode', 'github'] },
    { label: 'Game Dev', icons: ['godot', 'unity', 'unreal'] },
  ];

  return (
    <div className="w-full min-h-screen flex items-start justify-center p-3 md:p-5 bg-[#f0f0f0]">
      <section className="relative w-full max-w-[1536px] min-h-[calc(100vh-1.5rem)] rounded-[1.5rem] md:rounded-[3rem] overflow-hidden shadow-none flex flex-col items-center bg-white/10">
        <video
          autoPlay
          muted
          loop
          playsInline
          className="absolute inset-0 w-full h-full object-cover object-[65%] lg:object-center z-0 blur-xl opacity-40"
        >
          <source src="/JiruHub/assets/media/jiruhub.mp4" type="video/mp4" />
        </video>
        <div className="relative z-10 w-full h-full flex flex-col items-center">
          <Navbar />
          <div className="flex-1 w-full max-w-4xl px-6 pb-16 pt-4">
            {/* Header - Profile */}
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
              className="flex flex-col md:flex-row items-center gap-6 mb-10"
            >
              {avatar && (
                <img
                  src={avatar}
                  alt="Jepherson Medina"
                  className="w-24 h-24 md:w-32 md:h-32 rounded-full border-2 border-white/20 object-cover"
                />
              )}
              <div className="text-center md:text-left">
                <h1 className="text-3xl md:text-5xl font-normal text-white tracking-tight">
                  Jepherson Medina
                </h1>
                <p className="text-white/60 text-sm mt-1">
                  Developer | Content Creator | <span className="text-yellow-400">República Dominicana 🇩🇴</span>
                </p>
                <div className="flex items-center gap-4 mt-3 justify-center md:justify-start">
                  <div className="flex items-center gap-1.5">
                    <svg className="w-4 h-4 text-yellow-400" viewBox="0 0 24 24" fill="currentColor">
                      <path d="M12 2L15.09 8.26L22 9.27L17 14.14L18.18 21.02L12 17.77L5.82 21.02L7 14.14L2 9.27L8.91 8.26L12 2Z" />
                    </svg>
                    <span className="text-white/70 text-sm">{followers !== null ? followers : '—'} seguidores</span>
                  </div>
                  <div className="flex items-center gap-1.5">
                    <svg className="w-4 h-4 text-white/50" viewBox="0 0 24 24" fill="currentColor">
                      <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 15l-4-4 1.41-1.41L11 14.17l6.59-6.59L19 9l-8 8z" />
                    </svg>
                    <span className="text-white/50 text-sm">Disponible para colaborar</span>
                  </div>
                </div>
              </div>
            </motion.div>

            {/* Typing SVG */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ duration: 0.5, delay: 0.2 }}
              className="text-center mb-10"
            >
              <img
                src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&size=22&duration=3000&pause=1000&color=c0294a&center=true&vCenter=true&width=600&lines=Desarrollador+Autodidacta+%F0%9F%9A%80;Linux+%7C+Rust+%7C+Cloud+%7C+Open+Source;Optimizaci%C3%B3n+de+Sistemas+%E2%9A%A1;Creador+de+Contenido+Tech+%F0%9F%8E%AC;Dominican+Software+Engineer+%F0%9F%87%A9%F0%9F%87%B4"
                alt="Typing SVG"
                className="max-w-full mx-auto"
              />
            </motion.div>

            {/* Social Networks */}
            <motion.div
              initial={{ opacity: 0, y: 16 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.4, delay: 0.3 }}
              className="mb-10"
            >
              <h2 className="text-[rgb(45,45,45)] text-lg md:text-xl font-normal mb-4 text-center">🌐 Redes Sociales</h2>
              <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-3">
                {socials.map((s) => (
                  <a
                    key={s.name}
                    href={s.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="rounded-[1rem] bg-white/10 backdrop-blur-md border border-white/20 px-3 py-4 flex flex-col items-center gap-2 hover:bg-black/10 transition-colors"
                  >
                    <img src={s.icon} alt={s.name} className="w-10 h-10" />
                    <span className="text-[rgb(45,45,45)] text-xs font-normal">{s.name}</span>
                    <span className="text-[rgb(45,45,45)] text-[10px]">{s.user}</span>
                  </a>
                ))}
              </div>
            </motion.div>

            {/* Projects */}
            <motion.div
              initial={{ opacity: 0, y: 16 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.4, delay: 0.4 }}
              className="mb-10"
            >
              <h2 className="text-[rgb(45,45,45)] text-lg md:text-xl font-normal mb-4 text-center">🚀 Proyectos Destacados</h2>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                {projects.map((p) => (
                  <a
                    key={p.name}
                    href={p.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="rounded-[1.5rem] bg-white/10 backdrop-blur-md border border-white/20 px-5 py-4 hover:bg-black/10 transition-colors block"
                  >
                    <h3 className="text-[rgb(45,45,45)] text-sm md:text-base font-normal mb-1">{p.name}</h3>
                    <p className="text-[rgb(45,45,45)] text-xs md:text-sm leading-relaxed mb-3">{p.desc}</p>
                    <div className="flex items-center gap-3">
                      <img src={p.stars} alt="Stars" className="h-5" />
                      <img src={p.forks} alt="Forks" className="h-5" />
                    </div>
                  </a>
                ))}
              </div>
            </motion.div>

            {/* Tech Stack */}
            <motion.div
              initial={{ opacity: 0, y: 16 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.4, delay: 0.5 }}
              className="mb-10"
            >
              <h2 className="text-[rgb(45,45,45)] text-lg md:text-xl font-normal mb-4 text-center">🛠️ Stack Tecnológico</h2>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                {techStack.map((cat) => (
                  <motion.div
                    key={cat.label}
                    whileHover={{ scale: 1.04, y: -4 }}
                    transition={{ type: 'spring', stiffness: 300, damping: 15 }}
                    className="rounded-[1rem] bg-white/10 backdrop-blur-md border border-white/20 px-4 py-3 text-center"
                  >
                    <p className="text-[rgb(45,45,45)] text-xs mb-2">{cat.label}</p>
                    <div className="flex items-center justify-center gap-1.5 flex-wrap">
                      {cat.icons.map((icon) => (
                        <img
                          key={icon}
                          src={`https://skillicons.dev/icons?i=${icon}`}
                          alt={icon}
                          className="w-7 h-7"
                        />
                      ))}
                    </div>
                  </motion.div>
                ))}
              </div>
            </motion.div>

            {/* GitHub Stats */}
            <motion.div
              initial={{ opacity: 0, y: 16 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.4, delay: 0.6 }}
              className="mb-10"
            >
              <h2 className="text-[rgb(45,45,45)] text-lg md:text-xl font-normal mb-4 text-center">📈 GitHub Stats</h2>
              <div className="flex flex-col items-center gap-4">
                <div className="flex flex-col md:flex-row gap-4">
                  <img
                    src="https://github-readme-stats-eight-theta.vercel.app/api?username=jephersonRD&show_icons=true&theme=algolia&include_all_commits=true&count_private=true"
                    alt="GitHub Stats"
                    className="max-w-full rounded-xl"
                  />
                  <img
                    src="https://github-readme-stats-eight-theta.vercel.app/api/top-langs/?username=jephersonRD&layout=compact&langs_count=8&theme=algolia"
                    alt="Top Languages"
                    className="max-w-full rounded-xl"
                  />
                </div>
                <img
                  src="https://streak-stats.demolab.com/?user=jephersonRD&theme=algolia&hide_border=true&border_radius=8&ring=c0294a&fire=c0294a&currStreakLabel=c0294a"
                  alt="GitHub Streak"
                  className="max-w-full rounded-xl"
                />
                <img
                  src="https://github-readme-activity-graph.vercel.app/graph?username=jephersonRD&theme=react-dark&hide_border=true&area=true&color=c0294a&line=c0294a&point=fff&custom_title=Contribuciones"
                  alt="Activity Graph"
                  className="max-w-full rounded-xl"
                />
              </div>
            </motion.div>

            {/* Footer */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ duration: 0.5, delay: 0.7 }}
              className="text-center border-t border-white/10 pt-6"
            >
              <p className="text-[rgb(45,45,45)] text-xs leading-relaxed">
                © 2025 Jepherson Medina (@jephersonRD) • Full Stack Developer & Content Creator • República Dominicana 🇩🇴
                <br />
                Python | React | Rust | Django | System Optimization | Tech Education
              </p>
              <div className="flex items-center justify-center gap-3 mt-3 text-[rgb(45,45,45)] text-[10px]">
                <span>#jephersonRD</span>
                <span>#DevRD</span>
                <span>#ProgramadorDominicano</span>
                <span>#FullStackDeveloper</span>
                <span>#TechContentCreator</span>
              </div>
            </motion.div>
          </div>
        </div>
      </section>
    </div>
  );
}
