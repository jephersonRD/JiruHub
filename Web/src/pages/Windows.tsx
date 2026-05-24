import { useState } from 'react';
import { motion } from 'motion/react';
import { Copy, Check } from 'lucide-react';
import Navbar from '../components/Navbar';

const installCommand = 'irm https://raw.githubusercontent.com/jephersonRD/JiruHub/main/jiru-install/install.ps1 | iex';

export default function Windows() {
  const [copied, setCopied] = useState(false);

  const handleCopy = async () => {
    await navigator.clipboard.writeText(installCommand);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="w-full h-screen flex items-center justify-center p-3 md:p-5 bg-[#f0f0f0]">
      <section className="relative w-full max-w-[1536px] h-full rounded-[1.5rem] md:rounded-[3rem] overflow-hidden shadow-none flex flex-col items-center bg-white/10 group">
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
          <Navbar light />
          <div className="flex-1 flex items-center justify-center px-6 w-full">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6 }}
              className="w-full max-w-lg"
            >
              <div className="flex items-center gap-2 mb-4 justify-center">
                <svg fill="currentColor" strokeWidth="0" viewBox="0 0 448 512" className="w-5 h-5 text-[rgba(30,50,90,0.8)]">
                  <path d="M0 93.7l183.6-25.3v177.4H0V93.7zm0 324.6l183.6 25.3V268.4H0v149.9zm203.8 28L448 480V268.4H203.8v177.9zm0-380.6v180.1H448V32L203.8 65.7z" />
                </svg>
                <span className="text-[rgba(30,50,90,0.9)] text-lg font-normal">Instalar en Windows</span>
              </div>
              <div className="flex items-stretch gap-0 bg-[rgba(30,50,90,0.05)] rounded-full border border-[rgba(30,50,90,0.1)]">
                <pre className="flex-1 overflow-x-auto text-sm font-mono text-[rgba(30,50,90,0.9)] leading-relaxed px-5 py-3.5 whitespace-nowrap scrollbar-thin">
                  <code>{installCommand}</code>
                </pre>
                <button
                  onClick={handleCopy}
                  className="flex items-center justify-center px-5 py-3.5 bg-[rgba(30,50,90,0.08)] hover:bg-[rgba(30,50,90,0.12)] transition-colors rounded-r-full"
                >
                  {copied ? (
                    <Check className="w-4 h-4 text-green-600" />
                  ) : (
                    <Copy className="w-4 h-4 text-[rgba(30,50,90,0.8)]" />
                  )}
                </button>
              </div>
              <p className="mt-3 text-[12px] text-[rgba(30,50,90,0.5)] font-normal text-center">
                Pega esto en tu PowerShell
              </p>
            </motion.div>
          </div>
        </div>
      </section>
    </div>
  );
}
