import { motion } from 'motion/react';
import Navbar from '../components/Navbar';

const sections = [
  {
    title: 'Preamble',
    content: (
      <div className="space-y-3">
        <p>
          The GNU Affero General Public License is a free, copyleft license for software and other kinds of works, specifically designed to ensure cooperation with the community in the case of network server software.
        </p>
        <p>
          The licenses for most software and other practical works are designed to take away your freedom to share and change the works. By contrast, our General Public Licenses are intended to guarantee your freedom to share and change all versions of a program — to make sure it remains free software for all its users.
        </p>
        <p>
          When we speak of free software, we are referring to freedom, not price. Our General Public Licenses are designed to make sure that you have the freedom to distribute copies of free software (and charge for them if you wish), that you receive source code or can get it if you want it, that you can change the software or use pieces of it in new free programs, and that you know you can do these things.
        </p>
      </div>
    ),
  },
  {
    title: '0. Definitions',
    content: (
      <div className="space-y-2 text-sm">
        <p><strong className="text-yellow-500">"This License"</strong> refers to version 3 of the GNU Affero General Public License.</p>
        <p><strong className="text-yellow-500">"Copyright"</strong> also means copyright-like laws that apply to other kinds of works, such as semiconductor masks.</p>
        <p><strong className="text-yellow-500">"The Program"</strong> refers to any copyrightable work licensed under this License.</p>
        <p><strong className="text-yellow-500">"Modify"</strong> means to copy from or adapt all or part of the work in a fashion requiring copyright permission.</p>
        <p><strong className="text-yellow-500">"Covered work"</strong> means either the unmodified Program or a work based on the Program.</p>
        <p><strong className="text-yellow-500">"Propagate"</strong> means to do anything with it that would make you liable for infringement under copyright law.</p>
        <p><strong className="text-yellow-500">"Convey"</strong> means any kind of propagation that enables other parties to make or receive copies.</p>
      </div>
    ),
  },
  {
    title: '1. Source Code',
    content: (
      <div className="space-y-2 text-sm">
        <p>The <strong className="text-yellow-500">"source code"</strong> for a work means the preferred form for making modifications to it. <strong className="text-yellow-500">"Object code"</strong> means any non-source form.</p>
        <p>The <strong className="text-yellow-500">"Corresponding Source"</strong> for a work in object code form means all the source code needed to generate, install, run and modify the work, including scripts to control those activities.</p>
      </div>
    ),
  },
  {
    title: '2. Basic Permissions',
    content: (
      <p className="text-sm">
        All rights granted under this License are granted for the term of copyright on the Program, and are irrevocable provided the stated conditions are met. You may make, run and propagate covered works that you do not convey, without conditions so long as your license otherwise remains in force.
      </p>
    ),
  },
  {
    title: '3. Protecting Users\' Legal Rights From Anti-Circumvention Law',
    content: (
      <p className="text-sm">
        No covered work shall be deemed part of an effective technological measure under any applicable law. When you convey a covered work, you waive any legal power to forbid circumvention of technological measures to the extent such circumvention is effected by exercising rights under this License.
      </p>
    ),
  },
  {
    title: '4. Conveying Verbatim Copies',
    content: (
      <p className="text-sm">
        You may convey verbatim copies of the Program's source code as you receive it, in any medium, provided that you conspicuously publish on each copy an appropriate copyright notice; keep intact all notices stating that this License applies; and give all recipients a copy of this License along with the Program.
      </p>
    ),
  },
  {
    title: '5. Conveying Modified Source Versions',
    content: (
      <div className="space-y-2 text-sm">
        <p>You may convey a work based on the Program, provided that you also meet all of these conditions:</p>
        <ul className="list-disc list-inside space-y-1 pl-2">
          <li>The work must carry prominent notices stating that you modified it</li>
          <li>The work must carry prominent notices stating it is released under this License</li>
          <li>You must license the entire work under this License</li>
          <li>If the work has interactive user interfaces, each must display Appropriate Legal Notices</li>
        </ul>
      </div>
    ),
  },
  {
    title: '6. Conveying Non-Source Forms',
    content: (
      <p className="text-sm">
        You may convey a covered work in object code form under the terms of sections 4 and 5, provided that you also convey the machine-readable Corresponding Source under the terms of this License, in one of the specified ways (physical product, written offer, network server, or peer-to-peer transmission).
      </p>
    ),
  },
  {
    title: '7. Additional Terms',
    content: (
      <p className="text-sm">
        "Additional permissions" are terms that supplement this License by making exceptions from one or more of its conditions. When you convey a copy of a covered work, you may at your option remove any additional permissions from that copy.
      </p>
    ),
  },
  {
    title: '8. Termination',
    content: (
      <p className="text-sm">
        You may not propagate or modify a covered work except as expressly provided under this License. Any attempt otherwise to propagate or modify it is void, and will automatically terminate your rights under this License.
      </p>
    ),
  },
  {
    title: '9. Acceptance Not Required for Having Copies',
    content: (
      <p className="text-sm">
        You are not required to accept this License in order to receive or run a copy of the Program. However, nothing other than this License grants you permission to propagate or modify any covered work.
      </p>
    ),
  },
  {
    title: '10. Automatic Licensing of Downstream Recipients',
    content: (
      <p className="text-sm">
        Each time you convey a covered work, the recipient automatically receives a license from the original licensors to run, modify and propagate that work, subject to this License.
      </p>
    ),
  },
  {
    title: '11. Patents',
    content: (
      <p className="text-sm">
        A "contributor" is a copyright holder who authorizes use under this License. Each contributor grants you a non-exclusive, worldwide, royalty-free patent license under the contributor's essential patent claims.
      </p>
    ),
  },
  {
    title: '12-14. General Provisions',
    content: (
      <div className="space-y-2 text-sm">
        <p><strong>12.</strong> If conditions are imposed that contradict this License, you may not convey the covered work.</p>
        <p><strong>13.</strong> Modified versions must offer users interacting remotely an opportunity to receive the Corresponding Source.</p>
        <p><strong>14.</strong> The Free Software Foundation may publish revised versions of the GNU AGPL.</p>
      </div>
    ),
  },
  {
    title: '15. Disclaimer of Warranty',
    content: (
      <p className="text-sm font-medium">
        THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. THE PROGRAM IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.
      </p>
    ),
  },
  {
    title: '16. Limitation of Liability',
    content: (
      <p className="text-sm font-medium">
        IN NO EVENT WILL ANY COPYRIGHT HOLDER BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM.
      </p>
    ),
  },
];

export default function License() {
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
              <h1 className="text-2xl md:text-4xl font-normal text-[rgb(45,45,45)] tracking-tight mb-2 leading-tight">
                GNU AFFERO GENERAL PUBLIC LICENSE
              </h1>
              <p className="text-[rgb(45,45,45)] text-sm">Version 3, 19 November 2007</p>
              <p className="text-[rgb(45,45,45)] text-xs mt-3 max-w-xl mx-auto leading-relaxed">
                Copyright (C) 2007 Free Software Foundation, Inc.{' '}
                <a href="https://fsf.org/" target="_blank" rel="noopener noreferrer" className="underline hover:text-yellow-500 transition-colors">
                  https://fsf.org/
                </a>
                . Everyone is permitted to copy and distribute verbatim copies of this license document, but changing it is not allowed.
              </p>
            </motion.div>

            <div className="flex flex-col gap-5">
              {sections.map((section, i) => (
                <motion.div
                  key={i}
                  initial={{ opacity: 0, y: 16 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.4, delay: i * 0.04 }}
                  className="rounded-[1.5rem] bg-white/80 backdrop-blur-md border border-white/30 px-6 py-5"
                >
                  <h2 className="text-[rgb(45,45,45)] text-base md:text-lg font-normal mb-3">
                    {section.title}
                  </h2>
                  <div className="text-[rgb(45,45,45)] text-xs md:text-sm font-normal leading-relaxed space-y-3">
                    {section.content}
                  </div>
                </motion.div>
              ))}

              {/* How to Apply */}
              <motion.div
                initial={{ opacity: 0, y: 16 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.4, delay: sections.length * 0.04 }}
                className="rounded-[1.5rem] bg-white/80 backdrop-blur-md border border-white/30 px-6 py-5"
              >
                <h2 className="text-[rgb(45,45,45)] text-base md:text-lg font-normal mb-3">
                  How to Apply These Terms to Your New Programs
                </h2>
                <div className="text-[rgb(45,45,45)] text-xs md:text-sm font-normal leading-relaxed space-y-3">
                  <p>If you develop a new program, and you want it to be of the greatest possible use to the public, the best way to achieve this is to make it free software which everyone can redistribute and change under these terms.</p>
                  <p>To do so, attach the following notices to the program:</p>
                  <pre className="bg-[rgb(45,45,45)]/5 border border-[rgb(45,45,45)]/10 rounded-xl px-4 py-3 text-xs font-mono leading-relaxed whitespace-pre-wrap">
{`Free and open source Multi-functional application that supports
video, comics, novels extended source for Android, Windows.
JiruHub is a customized and modified version of Miru.

Copyright (C) 2026  jephersonRD

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.`}
                  </pre>
                  <p>You should also get your employer (if you work as a programmer) or school, if any, to sign a "copyright disclaimer" for the program.</p>
                  <p>
                    For more information on this, and how to apply and follow the GNU AGPL, see{' '}
                    <a href="https://www.gnu.org/licenses/" target="_blank" rel="noopener noreferrer" className="underline hover:text-yellow-500 transition-colors">
                      https://www.gnu.org/licenses/
                    </a>
                  </p>
                </div>
              </motion.div>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
