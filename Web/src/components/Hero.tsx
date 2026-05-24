import { motion } from 'motion/react';
import Navbar from './Navbar';
import HeroBadge from './HeroBadge';
import BottomLeftCard from './BottomLeftCard';
import BottomRightCorner from './BottomRightCorner';
import DownloadButtons from './DownloadButtons';

export default function Hero() {
  return (
    <div className="w-full h-screen flex items-center justify-center p-3 md:p-5 bg-[#f0f0f0]">
      <section className="relative w-full max-w-[1536px] h-full rounded-[1.5rem] md:rounded-[3rem] overflow-hidden shadow-none flex flex-col items-center bg-white/10 group">
        <video
          autoPlay
          muted
          loop
          playsInline
          className="absolute inset-0 w-full h-full object-cover object-[65%] lg:object-center z-0 blur-[2.5px]"
        >
          <source
            src="/JiruHub/assets/media/jiruhub.mp4"
            type="video/mp4"
          />
        </video>
        <div className="relative z-10 w-full h-full flex flex-col items-center">
          <Navbar />
          <div className="w-full flex flex-col items-center pt-8 px-6 text-center max-w-4xl">
            <HeroBadge />
            <motion.h1
              initial={{ opacity: 0, scale: 0.98 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.8, delay: 0.2 }}
              className="text-4xl sm:text-5xl md:text-6xl lg:text-[80px] font-normal text-white mb-2 tracking-tight leading-[1.05]"
            >
              JiruHub
            </motion.h1>
            <motion.p
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ duration: 0.8, delay: 0.4 }}
              className="text-sm sm:text-base md:text-lg text-white opacity-80 leading-relaxed max-w-xl font-normal"
            >
              Aplicación multiplataforma enfocada en anime, manga y películas en español mediante un sistema de extensiones.
            </motion.p>
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.55 }}
              className="flex items-center justify-center gap-4 mt-4"
            >
              <svg width="36" height="36" viewBox="0 0 256 256" fill="none" xmlns="http://www.w3.org/2000/svg" className="opacity-80 hover:opacity-100 transition-opacity">
                <rect width="256" height="256" fill="#242938" rx="60"/>
                <path fill="#00D8FF" d="M128.001 146.951C138.305 146.951 146.657 138.598 146.657 128.295C146.657 117.992 138.305 109.639 128.001 109.639C117.698 109.639 109.345 117.992 109.345 128.295C109.345 138.598 117.698 146.951 128.001 146.951Z"/>
                <path fill-rule="evenodd" stroke="#00D8FF" stroke-width="8.911" d="M128.002 90.3633C153.05 90.3633 176.319 93.9575 193.864 99.9976C215.003 107.275 228 118.306 228 128.295C228 138.704 214.226 150.423 191.525 157.944C174.363 163.63 151.779 166.598 128.002 166.598C103.624 166.598 80.5389 163.812 63.1834 157.881C41.2255 150.376 28 138.506 28 128.295C28 118.387 40.4096 107.441 61.2515 100.175C78.8617 94.0353 102.705 90.3633 127.998 90.3633H128.002Z" clip-rule="evenodd"/>
                <path fill-rule="evenodd" stroke="#00D8FF" stroke-width="8.911" d="M94.9811 109.438C107.495 87.7402 122.232 69.3783 136.23 57.1971C153.094 42.5206 169.144 36.7728 177.796 41.7623C186.813 46.9623 190.084 64.7496 185.259 88.1712C181.614 105.879 172.9 126.925 161.021 147.523C148.842 168.641 134.897 187.247 121.09 199.315C103.619 214.587 86.7284 220.114 77.8833 215.013C69.3003 210.067 66.0181 193.846 70.1356 172.161C73.6145 153.838 82.3451 131.349 94.977 109.438L94.9811 109.438Z" clip-rule="evenodd"/>
                <path fill-rule="evenodd" stroke="#00D8FF" stroke-width="8.911" d="M95.0123 147.578C82.4633 125.904 73.9194 103.962 70.3531 85.7517C66.0602 63.8109 69.0954 47.0355 77.7401 42.0315C86.7485 36.8163 103.792 42.866 121.674 58.7437C135.194 70.7479 149.077 88.8052 160.99 109.383C173.204 130.481 182.358 151.856 185.919 169.844C190.425 192.608 186.778 210.001 177.941 215.116C169.367 220.08 153.676 214.825 136.945 200.427C122.809 188.263 107.685 169.468 95.0123 147.578Z" clip-rule="evenodd"/>
              </svg>
              <svg width="36" height="36" viewBox="0 0 256 256" fill="none" xmlns="http://www.w3.org/2000/svg" className="opacity-80 hover:opacity-100 transition-opacity">
                <rect width="256" height="256" rx="60" fill="#242938"/>
                <path d="M227.088 57.6016L133.256 225.389C131.318 228.854 126.341 228.874 124.375 225.427L28.6823 57.6177C26.54 53.861 29.7524 49.3105 34.0096 50.0715L127.942 66.8613C128.541 66.9684 129.155 66.9674 129.754 66.8582L221.722 50.0955C225.965 49.3222 229.192 53.8374 227.088 57.6016Z" fill="url(#paint0_linear_307_179)"/>
                <path d="M172.687 28.0492L103.249 41.6554C102.107 41.879 101.262 42.8462 101.194 44.007L96.9221 116.148C96.8216 117.847 98.3821 119.166 100.04 118.783L119.373 114.322C121.182 113.905 122.816 115.498 122.445 117.317L116.701 145.443C116.314 147.336 118.092 148.954 119.94 148.393L131.881 144.765C133.732 144.203 135.511 145.826 135.119 147.721L125.991 191.9C125.42 194.664 129.096 196.171 130.629 193.801L131.653 192.219L188.235 79.2992C189.183 77.4085 187.549 75.2526 185.472 75.6534L165.573 79.494C163.703 79.8545 162.112 78.113 162.639 76.2834L175.628 31.2582C176.156 29.4255 174.559 27.6825 172.687 28.0492Z" fill="url(#paint1_linear_307_179)"/>
                <defs>
                  <linearGradient id="paint0_linear_307_179" x1="26.3459" y1="44.075" x2="143.127" y2="202.673" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#41D1FF"/>
                    <stop offset="1" stop-color="#BD34FE"/>
                  </linearGradient>
                  <linearGradient id="paint1_linear_307_179" x1="122.551" y1="31.7433" x2="143.676" y2="176.66" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#FFEA83"/>
                    <stop offset="0.0833333" stop-color="#FFDD35"/>
                    <stop offset="1" stop-color="#FFA800"/>
                  </linearGradient>
                </defs>
              </svg>
              <svg width="36" height="36" viewBox="0 0 256 256" fill="none" xmlns="http://www.w3.org/2000/svg" className="opacity-80 hover:opacity-100 transition-opacity">
                <rect width="256" height="256" fill="#242938" rx="60"/>
                <path fill="url(#paint0_linear_2_119)" fill-rule="evenodd" d="M83 110C88.9991 86.0009 104.001 74 128 74C164 74 168.5 101 186.5 105.5C198.501 108.501 209 104.001 218 92C212.001 115.999 196.999 128 173 128C137 128 132.5 101 114.5 96.5C102.499 93.4991 92 97.9991 83 110ZM38 164C43.9991 140.001 59.0009 128 83 128C119 128 123.5 155 141.5 159.5C153.501 162.501 164 158.001 173 146C167.001 169.999 151.999 182 128 182C92 182 87.5 155 69.5 150.5C57.4991 147.499 47 151.999 38 164Z" clip-rule="evenodd"/>
                <defs>
                  <linearGradient id="paint0_linear_2_119" x1="86.5" x2="163.5" y1="74" y2="185.5" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#32B1C1"/>
                    <stop offset="1" stop-color="#14C6B7"/>
                  </linearGradient>
                </defs>
              </svg>
            </motion.div>
            <DownloadButtons />
          </div>
          <BottomLeftCard />
          <BottomRightCorner />
        </div>
      </section>
    </div>
  );
}
