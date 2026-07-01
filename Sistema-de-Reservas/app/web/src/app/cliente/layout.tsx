'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { Button } from '@/app/components/ui/button';

export default function ClienteLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter();

  useEffect(() => {
    const user = localStorage.getItem('user');
    if (!user) {
      router.push('/auth/login');
    }
  }, [router]);

  const handleLogout = () => {
    localStorage.removeItem('user');
    router.push('/auth/login');
  };

  return (
    <div className="min-h-screen bg-slate-50">
      <nav className="bg-white border-b px-6 py-4 flex items-center justify-between">
        <div className="flex items-center gap-6">
          <span className="font-bold text-lg">Hotel Los Andes</span>
          <Link href="/cliente/inicio" className="text-sm text-slate-600 hover:text-slate-900">Habitaciones</Link>
          <Link href="/cliente/mis-reservas" className="text-sm text-slate-600 hover:text-slate-900">Mis Reservas</Link>
        </div>
        <Button variant="outline" size="sm" onClick={handleLogout}>Cerrar sesión</Button>
      </nav>
      <main className="p-6">{children}</main>
    </div>
  );
}