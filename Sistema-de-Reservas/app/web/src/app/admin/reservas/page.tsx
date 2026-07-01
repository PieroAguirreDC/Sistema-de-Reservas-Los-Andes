'use client';

import { useEffect, useState } from 'react';
import { reservasAPI } from '@/frontend/lib/api';
import { Badge } from '@/frontend/components/ui/badge';
import { Button } from '@/frontend/components/ui/button';

interface Reserva {
  id: string;
  usuario_id: string;
  habitacion_id: string;
  fecha_inicio: string;
  fecha_fin: string;
  estado: string;
  created_at: string;
}

export default function ReservasAdminPage() {
  const [reservas, setReservas] = useState<Reserva[]>([]);

  useEffect(() => {
    reservasAPI.getAll().then(setReservas).catch(console.error);
  }, []);

  const handleEstado = async (id: string, estado: string) => {
    try {
      await reservasAPI.update(id, { estado });
      const data = await reservasAPI.getAll();
      setReservas(data);
    } catch (err) {
      console.error(err);
    }
  };

  const colorEstado: Record<string, 'default' | 'secondary' | 'destructive'> = {
    pendiente: 'secondary',
    confirmada: 'default',
    cancelada: 'destructive',
  };

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Reservas</h1>
      <div className="rounded-md border bg-white overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-slate-50 border-b">
            <tr>
              <th className="text-left p-4">Usuario</th>
              <th className="text-left p-4">Habitación</th>
              <th className="text-left p-4">Fechas</th>
              <th className="text-left p-4">Estado</th>
              <th className="text-left p-4">Acciones</th>
            </tr>
          </thead>
          <tbody>
            {reservas.map(r => (
              <tr key={r.id} className="border-b last:border-0">
                <td className="p-4 text-xs text-slate-500">{r.usuario_id}</td>
                <td className="p-4 text-xs text-slate-500">{r.habitacion_id}</td>
                <td className="p-4">{r.fecha_inicio} → {r.fecha_fin}</td>
                <td className="p-4">
                  <Badge variant={colorEstado[r.estado] || 'secondary'}>{r.estado}</Badge>
                </td>
                <td className="p-4 flex gap-2">
                  <Button size="sm" onClick={() => handleEstado(r.id, 'confirmada')}>Confirmar</Button>
                  <Button size="sm" variant="destructive" onClick={() => handleEstado(r.id, 'cancelada')}>Cancelar</Button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}