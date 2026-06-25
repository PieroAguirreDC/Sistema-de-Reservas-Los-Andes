'use client';

import { useEffect, useState } from 'react';
import { reservasAPI } from '@/app/lib/api';
import { Badge } from '@/app/components/ui/badge';
import { Button } from '@/app/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/app/components/ui/card';

interface Reserva {
  id: string;
  usuario_id: string;
  habitacion_id: string;
  fecha_inicio: string;
  fecha_fin: string;
  estado: string;
}

export default function MisReservasPage() {
  const [reservas, setReservas] = useState<Reserva[]>([]);

  useEffect(() => {
    const user = JSON.parse(localStorage.getItem('user') || '{}');
    reservasAPI.getAll()
      .then(data => setReservas(data.filter((r: Reserva) => r.usuario_id === user.id)))
      .catch(console.error);
  }, []);

  const handleCancelar = async (id: string) => {
    if (!confirm('¿Cancelar esta reserva?')) return;
    try {
      await reservasAPI.update(id, { estado: 'cancelada' });
      const user = JSON.parse(localStorage.getItem('user') || '{}');
      const data = await reservasAPI.getAll();
      setReservas(data.filter((r: Reserva) => r.usuario_id === user.id));
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
      <h1 className="text-2xl font-bold">Mis Reservas</h1>
      {reservas.length === 0 ? (
        <p className="text-slate-500">No tienes reservas aún.</p>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {reservas.map(r => (
            <Card key={r.id}>
              <CardHeader className="flex flex-row items-center justify-between">
                <CardTitle className="text-base">Hab. {r.habitacion_id}</CardTitle>
                <Badge variant={colorEstado[r.estado] || 'secondary'}>{r.estado}</Badge>
              </CardHeader>
              <CardContent className="space-y-2">
                <p className="text-sm text-slate-500">
                  {r.fecha_inicio} → {r.fecha_fin}
                </p>
                {r.estado === 'pendiente' && (
                  <Button variant="destructive" size="sm" onClick={() => handleCancelar(r.id)}>
                    Cancelar reserva
                  </Button>
                )}
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}