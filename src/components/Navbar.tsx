import { ChevronRight, ArrowUpRight } from 'lucide-react';
import { motion } from 'motion/react';
import { Link } from 'react-router-dom';

function NavItem({ label, hasDropdown, to }: { label: string; hasDropdown?: boolean; to?: string }) {
  if (to) {
    return (
      <li className="cursor-pointer hover:opacity-70 transition-opacity flex items-center gap-1 group">
        <Link to={to}>{label}</Link>
        {hasDropdown && (
          <ChevronRight className="w-4 h-4 transition-transform group-hover:translate-x-0.5" />
        )}
      </li>
    );
  }
  return (
    <li className="cursor-pointer hover:opacity-70 transition-opacity flex items-center gap-1 group">
      {label}
      {hasDropdown && (
        <ChevronRight className="w-4 h-4 transition-transform group-hover:translate-x-0.5" />
      )}
    </li>
  );
}

export default function Navbar({ light }: { light?: boolean }) {
  return (
    <nav className="flex items-center justify-between py-6 px-6 md:px-10 w-full relative z-10">
      <div className="flex-1 hidden md:block" />
      <ul className={`hidden md:flex items-center gap-8 font-normal text-sm ${light ? 'text-[rgb(45,45,45)]' : 'text-white'}`}>
        <NavItem label="Home" to="/" />
        <NavItem label="FAQ" to="/faq" />
        <NavItem label="Desarrolladores" to="/developers" />
        <NavItem label="Licencia" to="/license" />
      </ul>
      <div className="md:hidden">
        <span className="font-regular tracking-tighter text-xl text-[rgba(30,50,90,0.9)]">RIVR</span>
      </div>
      <div className="flex-1 flex justify-end">
        <motion.a
          href="https://github.com/jephersonRD/JiruHub"
          target="_blank"
          rel="noopener noreferrer"
          whileHover={{ scale: 1.02 }}
          whileTap={{ scale: 0.98 }}
          className="flex items-center bg-white text-[rgba(30,50,90,0.9)] rounded-full pl-2 pr-4 md:pr-6 py-1.5 md:py-2 gap-2 md:gap-3 hover:bg-white/80 transition-colors group"
        >
          <div className="bg-[rgba(30,50,90,0.1)] p-1 md:p-1.5 rounded-full flex items-center justify-center">
            <ArrowUpRight className="w-4 h-4 md:w-5 md:h-5 text-[rgba(30,50,90,0.9)]" />
          </div>
          <span className="text-xs md:text-sm font-normal">Github oficial</span>
        </motion.a>
      </div>
    </nav>
  );
}
