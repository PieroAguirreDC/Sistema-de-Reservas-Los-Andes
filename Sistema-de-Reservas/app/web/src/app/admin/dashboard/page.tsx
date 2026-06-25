'use client';

import { useEffect, useState } from 'react';
import { habitacionesAPI, reservasAPI, usuariosAPI } from '@/frontend/lib/api';
import { Card, CardContent, CardHeader, CardTitle } from '@/frontend/components/ui/card';

export default function DashboardPage() {
  const [stats, setStats] = useState({ habitaciones: 0, reservas: 0, usuarios: 0 });

  useEffect(() => {
    const loadStats = async () => {
      try {
        const [habitaciones, reservas, usuarios] = await Promise.all([
          habitacionesAPI.getAll(),
          reservasAPI.getAll(),
          usuariosAPI.getAll(),
        ]);
        setStats({
          habitaciones: habitaciones.length,
          reservas: reservas.length,
          usuarios: usuarios.length,
        });
      } catch (err) {
        console.error(err);
      }
    };
    loadStats();
  }, []);

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Dashboard</h1>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card>
          <CardHeader><CardTitle className="text-sm text-slate-500">Habitaciones</CardTitle></CardHeader>
          <CardContent><p className="text-4xl font-bold">{stats.habitaciones}</p></CardContent>
        </Card>
        <Card>
          <CardHeader><CardTitle className="text-sm text-slate-500">Reservas</CardTitle></CardHeader>
          <CardContent><p className="text-4xl font-bold">{stats.reservas}</p></CardContent>
        </Card>
        <Card>
          <CardHeader><CardTitle className="text-sm text-slate-500">Usuarios</CardTitle></CardHeader>
          <CardContent><p className="text-4xl font-bold">{stats.usuarios}</p></CardContent>
        </Card>
      </div>
    </div>
  );
}