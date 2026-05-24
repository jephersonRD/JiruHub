import { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { ChevronDown } from 'lucide-react';
import Navbar from '../components/Navbar';

const faqs = [
  {
    q: '¿Qué es JiruHub?',
    a: 'JiruHub es una aplicación multiplataforma basada en un fork personalizado de Miru App, enfocada en anime, manga y películas en español mediante un sistema de extensiones.',
  },
  {
    q: '¿JiruHub es compatible con Windows y Linux?',
    a: 'Sí. Actualmente JiruHub tiene soporte para Linux y Windows mediante instaladores automáticos desde terminal y PowerShell.',
  },
  {
    q: '¿Cómo agrego el repositorio de extensiones?',
    a: 'Debes ir a: Ajustes → Extensiones → Repositorios. Luego presiona + y agrega esta URL:\n\nhttps://raw.githubusercontent.com/jephersonRD/JiruHub/main/index.json\n\nDespués pulsa Recargar y aparecerán las extensiones disponibles.',
  },
  {
    q: '¿Qué contenido puedo ver en JiruHub?',
    a: 'Puedes ver anime online, películas, series y acceder a múltiples fuentes desde una sola aplicación usando extensiones compatibles.',
  },
  {
    q: '¿Puedo crear mis propias extensiones?',
    a: 'Sí. JiruHub permite desarrollar extensiones en JavaScript utilizando funciones como latest(), search(), detail() y watch().',
  },
  {
    q: '¿JiruHub es código abierto?',
    a: 'Sí. El proyecto es open source y está distribuido bajo la licencia AGPL-3.0, permitiendo modificar y contribuir al proyecto.',
  },
];

function FaqItem({ question, answer }: { question: string; answer: string }) {
  const [open, setOpen] = useState(false);

  return (
    <motion.div
      layout
      className="rounded-[1.5rem] bg-white/10 backdrop-blur-md border border-white/20 overflow-hidden"
    >
      <button
        onClick={() => setOpen(!open)}
        className="w-full flex items-center justify-between px-6 py-4 text-left text-white text-sm md:text-base font-normal"
      >
        <span>{question}</span>
        <ChevronDown
          className={`w-4 h-4 text-white/70 transition-transform duration-300 ${open ? 'rotate-180' : ''}`}
        />
      </button>
      <AnimatePresence initial={false}>
        {open && (
          <motion.div
            key="answer"
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.3, ease: 'easeInOut' }}
            className="overflow-hidden"
          >
            <div className="px-6 pb-4 text-[rgb(45,45,45)] text-xs md:text-sm font-normal leading-relaxed whitespace-pre-line">
              {answer}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}

export default function Faq() {
  return (
    <div className="w-full min-h-screen flex items-center justify-center p-3 md:p-5 bg-[#f0f0f0]">
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
          <Navbar light />
          <div className="flex-1 w-full max-w-2xl px-6 pb-12">
            <motion.h1
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
              className="text-3xl md:text-4xl font-normal text-white text-center mb-8 tracking-tight"
            >
              FAQ — JiruHub
            </motion.h1>
            <div className="flex flex-col gap-4">
              {faqs.map((faq, i) => (
                <motion.div
                  key={i}
                  initial={{ opacity: 0, y: 16 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.4, delay: i * 0.08 }}
                >
                  <FaqItem question={faq.q} answer={faq.a} />
                </motion.div>
              ))}
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
