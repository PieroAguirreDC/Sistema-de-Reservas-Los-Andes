'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';

export default function HomePage() {
  const router = useRouter();

  useEffect(() => {
    const user = localStorage.getItem('user');
    if (!user) {
      router.push('/auth/login');
      return;
    }
    const parsed = JSON.parse(user);
    if (parsed.rol === 'admin') {
      router.push('/admin/dashboard');
    } else {
      router.push('/cliente/inicio');
    }
  }, [router]);

  return null;
}