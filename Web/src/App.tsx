import { HashRouter, Routes, Route } from 'react-router-dom';
import Home from './pages/Home';
import Linux from './pages/Linux';
import Faq from './pages/Faq';
import Windows from './pages/Windows';
import Docs from './pages/Docs';
import Developers from './pages/Developers';
import License from './pages/License';

function App() {
  return (
    <HashRouter>
      <main className="min-h-screen bg-[#f0f0f0]">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/linux" element={<Linux />} />
          <Route path="/faq" element={<Faq />} />
          <Route path="/windows" element={<Windows />} />
          <Route path="/docs" element={<Docs />} />
          <Route path="/developers" element={<Developers />} />
          <Route path="/license" element={<License />} />
        </Routes>
      </main>
    </HashRouter>
  );
}

export default App;
