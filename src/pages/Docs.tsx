import { motion } from 'motion/react';
import Navbar from '../components/Navbar';

const sections = [
  {
    title: '1. Introducción',
    content: (
      <div className="space-y-3">
        <p>
          JiruHub es una aplicación multiplataforma enfocada en el consumo de anime, manga, películas y series en español mediante un sistema moderno de <span className="text-yellow-500">extensiones</span>. El proyecto nace como un fork personalizado de{' '}
          <strong className="text-yellow-500">Miru App</strong>, adaptado específicamente para la comunidad hispanohablante por{' '}
          <strong className="text-yellow-500">JephMD</strong>.
        </p>
        <p>
          Su objetivo principal es ofrecer una experiencia más rápida, limpia y flexible para acceder a contenido multimedia desde múltiples fuentes dentro de una sola aplicación.
        </p>
        <p>
          <a href="https://github.com/jephersonRD/JiruHub" target="_blank" rel="noopener noreferrer" className="text-[rgb(45,45,45)] underline hover:text-yellow-500 transition-colors">
            JiruHub GitHub Repository →
          </a>
        </p>
      </div>
    ),
  },
  {
    title: '2. Filosofía del Proyecto',
    content: (
      <p>
        JiruHub fue diseñado pensando en la simplicidad y la libertad del usuario. En lugar de depender de una única fuente de contenido, utiliza un sistema modular basado en <span className="text-yellow-500">extensiones JavaScript</span> que permite agregar nuevas plataformas fácilmente. Esto hace que la aplicación sea altamente escalable y personalizable, permitiendo que la comunidad pueda contribuir creando nuevas extensiones o mejorando las existentes.
      </p>
    ),
  },
  {
    title: '3. Compatibilidad Multiplataforma',
    content: (
      <div className="space-y-4">
        <p>
          Actualmente JiruHub cuenta con soporte oficial para sistemas <span className="text-yellow-500">Linux</span> y <span className="text-yellow-500">Windows</span>. El proyecto incluye instaladores automáticos preparados para detectar la plataforma del usuario y descargar automáticamente la última versión publicada desde GitHub Releases.
        </p>
        <div>
          <p className="text-xs md:text-sm text-[rgb(45,45,45)] mb-2 font-mono">Linux</p>
          <pre className="bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-xs md:text-sm font-mono text-[rgb(45,45,45)] overflow-x-auto scrollbar-thin whitespace-nowrap">
            curl -fsSL https://raw.githubusercontent.com/jephersonRD/JiruHub/main/jiru-install/install.sh | bash
          </pre>
        </div>
        <div>
          <p className="text-xs md:text-sm text-[rgb(45,45,45)] mb-2 font-mono">Windows (PowerShell)</p>
          <pre className="bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-xs md:text-sm font-mono text-[rgb(45,45,45)] overflow-x-auto scrollbar-thin whitespace-nowrap">
            irm https://raw.githubusercontent.com/jephersonRD/JiruHub/main/jiru-install/install.ps1 | iex
          </pre>
        </div>
      </div>
    ),
  },
  {
    title: '4. Sistema de Extensiones',
    content: (
      <div className="space-y-3">
        <p>
          Uno de los pilares principales de JiruHub es su arquitectura basada en extensiones. Cada extensión corresponde a un archivo <code className="text-[rgb(45,45,45)] bg-white/30 px-1.5 py-0.5 rounded text-xs">.js</code> ubicado dentro de la carpeta <code className="text-[rgb(45,45,45)] bg-white/30 px-1.5 py-0.5 rounded text-xs">extensions/</code>. Estas extensiones son responsables de obtener información desde sitios compatibles con el ecosistema Miru y transformarla en contenido reproducible dentro de la aplicación.
        </p>
        <p>El sistema permite:</p>
        <ul className="list-disc list-inside space-y-1 text-[rgb(45,45,45)]">
          <li>Buscar contenido</li>
          <li>Obtener episodios</li>
          <li>Cargar información detallada</li>
          <li>Generar enlaces de reproducción</li>
          <li>Acceder a múltiples fuentes desde una sola interfaz</li>
        </ul>
      </div>
    ),
  },
  {
    title: '5. Funciones Principales de las Extensiones',
    content: (
      <div className="space-y-3">
        <p>Cada extensión implementa funciones obligatorias que permiten la integración correcta con la aplicación:</p>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs md:text-sm">
            <thead>
              <tr className="border-b border-white/10">
                <th className="py-2 pr-4 text-[rgb(45,45,45)] font-normal">Función</th>
                <th className="py-2 text-[rgb(45,45,45)] font-normal">Descripción</th>
              </tr>
            </thead>
            <tbody className="text-[rgb(45,45,45)]">
              <tr className="border-b border-white/5">
                <td className="py-2 pr-4 font-mono text-yellow-500">latest(page)</td>
                <td className="py-2">Obtiene los contenidos más recientes</td>
              </tr>
              <tr className="border-b border-white/5">
                <td className="py-2 pr-4 font-mono text-yellow-500">search(kw, page, filter)</td>
                <td className="py-2">Realiza búsquedas por palabra clave</td>
              </tr>
              <tr className="border-b border-white/5">
                <td className="py-2 pr-4 font-mono text-yellow-500">detail(url)</td>
                <td className="py-2">Obtiene información detallada</td>
              </tr>
              <tr>
                <td className="py-2 pr-4 font-mono text-yellow-500">watch(url)</td>
                <td className="py-2">Genera enlaces de reproducción válidos</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    ),
  },
  {
    title: '6. Repositorio de Extensiones',
    content: (
      <div className="space-y-3">
        <p>
          El proyecto incluye un repositorio centralizado de extensiones que puede agregarse manualmente desde la aplicación. Para hacerlo, el usuario debe ir a:
        </p>
        <p className="text-[rgb(45,45,45)] font-mono text-sm bg-white/5 border border-white/10 rounded-xl px-4 py-2 inline-block">
          Ajustes → Extensiones → Repositorios
        </p>
        <p>Luego agregar la siguiente URL:</p>
        <pre className="bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-xs md:text-sm font-mono text-[rgb(45,45,45)] overflow-x-auto scrollbar-thin">
          https://raw.githubusercontent.com/jephersonRD/JiruHub/main/index.json
        </pre>
        <p>Una vez añadido el repositorio, la aplicación mostrará automáticamente todas las extensiones disponibles para instalar.</p>
      </div>
    ),
  },
  {
    title: '7. Estructura del Proyecto',
    content: (
      <div className="space-y-3">
        <p>La estructura del repositorio está organizada para separar correctamente extensiones, recursos gráficos y configuraciones internas.</p>
        <pre className="bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-xs md:text-sm font-mono text-[rgb(45,45,45)] leading-relaxed">
{`JiruHub/
├── index.json
├── extensions/
├── icons/
├── assets/
├── README.md
└── .github/`}
        </pre>
        <ul className="list-disc list-inside space-y-1 text-[rgb(45,45,45)]">
          <li><code className="text-[rgb(45,45,45)] bg-white/30 px-1.5 py-0.5 rounded text-xs">extensions/</code> — contiene las extensiones <span className="text-yellow-500">JavaScript</span></li>
          <li><code className="text-[rgb(45,45,45)] bg-white/30 px-1.5 py-0.5 rounded text-xs">icons/</code> — almacena los iconos de cada fuente</li>
          <li><code className="text-[rgb(45,45,45)] bg-white/30 px-1.5 py-0.5 rounded text-xs">assets/</code> — incluye capturas y recursos visuales</li>
          <li><code className="text-[rgb(45,45,45)] bg-white/30 px-1.5 py-0.5 rounded text-xs">.github/</code> — contiene workflows y automatizaciones</li>
        </ul>
      </div>
    ),
  },
  {
    title: '8. Código Abierto y Comunidad',
    content: (
      <div className="space-y-3">
        <p>
          JiruHub es un proyecto <span className="text-yellow-500">open source</span> distribuido bajo la licencia <strong className="text-yellow-500">AGPL-3.0</strong>. Esto significa que cualquier usuario puede estudiar, modificar y contribuir al código del proyecto respetando las condiciones de la licencia.
        </p>
        <p>La comunidad puede participar mediante:</p>
        <ul className="list-disc list-inside space-y-1 text-[rgb(45,45,45)]">
          <li>Reportes de errores</li>
          <li>Creación de extensiones</li>
          <li>Pull Requests</li>
          <li>Sugerencias de mejoras</li>
          <li>Traducciones y documentación</li>
        </ul>
        <p>
          <a href="https://github.com/jephersonRD/JiruHub/issues" target="_blank" rel="noopener noreferrer" className="text-[rgb(45,45,45)] underline hover:text-yellow-500 transition-colors">
            JiruHub Issues →
          </a>
        </p>
      </div>
    ),
  },
  {
    title: '9. Futuro del Proyecto',
    content: (
      <p>
        El objetivo a largo plazo de JiruHub es convertirse en una de las principales plataformas open source de entretenimiento en español. El proyecto busca expandir el ecosistema de extensiones, mejorar la interfaz de usuario, optimizar el rendimiento multiplataforma y ofrecer una experiencia moderna tanto en escritorio como en futuros dispositivos compatibles.
      </p>
    ),
  },
];

export default function Docs() {
  return (
    <div className="w-full min-h-screen flex items-start justify-center p-3 md:p-5 bg-[#f0f0f0]">
      <section className="relative w-full max-w-[1536px] min-h-[calc(100vh-1.5rem)] rounded-[1.5rem] md:rounded-[3rem] overflow-hidden shadow-none flex flex-col items-center bg-white/30">
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
          <div className="flex-1 w-full max-w-3xl px-6 pb-16 pt-4">
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
              className="mb-10 text-center"
            >
              <h1 className="text-3xl md:text-5xl font-normal text-[rgb(45,45,45)] tracking-tight mb-2">
                Documentación Oficial
              </h1>
              <p className="text-[rgb(45,45,45)] text-sm">
                Versión modificada de Miru App — creada por{' '}
                <a
                  href="https://github.com/jephersonRD"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-[rgb(45,45,45)] underline hover:text-yellow-500 transition-colors"
                >
                  JephMD
                </a>
              </p>
            </motion.div>
            <div className="flex flex-col gap-5">
              {sections.map((section, i) => (
                <motion.div
                  key={i}
                  initial={{ opacity: 0, y: 16 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.4, delay: i * 0.05 }}
                  className="rounded-[1.5rem] bg-white/30 backdrop-blur-md border border-white/30 px-6 py-5"
                >
                  <h2 className="text-[rgb(45,45,45)] text-base md:text-lg font-normal mb-3">
                    {section.title}
                  </h2>
                  <div className="text-[rgb(45,45,45)] text-xs md:text-sm font-normal leading-relaxed space-y-3">
                    {section.content}
                  </div>
                </motion.div>
              ))}
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
