'use client';

import { useEffect, useState } from 'react';
import { habitacionesAPI, reservasAPI } from '@/app/lib/api';
import { Card, CardContent, CardHeader, CardTitle } from '@/app/components/ui/card';
import { Badge } from '@/app/components/ui/badge';
import { Button } from '@/app/components/ui/button';
import { Input } from '@/app/components/ui/input';
import { Label } from '@/app/components/ui/label';

interface Habitacion {
  id: string;
  numero: string;
  tipo: string;
  precio_por_noche: number;
  disponible: boolean;
  descripcion: string;
}

export default function InicioPage() {
  const [habitaciones, setHabitaciones] = useState<Habitacion[]>([]);
  const [selected, setSelected] = useState<Habitacion | null>(null);
  const [fechaInicio, setFechaInicio] = useState('');
  const [fechaFin, setFechaFin] = useState('');
  const [loading, setLoading] = useState(false);
  const [mensaje, setMensaje] = useState('');

  useEffect(() => {
    habitacionesAPI.getAll()
      .then(data => setHabitaciones(data.filter((h: Habitacion) => h.disponible)))
      .catch(console.error);
  }, []);

  const handleReservar = async () => {
    if (!selected || !fechaInicio || !fechaFin) return;
    setLoading(true);
    setMensaje('');
    try {
      const user = JSON.parse(localStorage.getItem('user') || '{}');
      await reservasAPI.create({
        usuario_id: user.id,
        habitacion_id: selected.id,
        fecha_inicio: fechaInicio,
        fecha_fin: fechaFin,
      });
      setMensaje('¡Reserva creada exitosamente!');
      setSelected(null);
      setFechaInicio('');
      setFechaFin('');
    } catch (err: unknown) {
      setMensaje(err instanceof Error ? err.message : 'Error al crear reserva');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Habitaciones Disponibles</h1>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {habitaciones.map(h => (
          <Card
            key={h.id}
            className={`cursor-pointer transition-all ${selected?.id === h.id ? 'ring-2 ring-slate-900' : ''}`}
            onClick={() => setSelected(h)}
          >
            <CardHeader className="flex flex-row items-center justify-between">
              <CardTitle>Hab. {h.numero}</CardTitle>
              <Badge>Disponible</Badge>
            </CardHeader>
            <CardContent className="space-y-1">
              <p className="text-sm text-slate-500">{h.tipo}</p>
              <p className="font-semibold">S/. {h.precio_por_noche} / noche</p>
              <p className="text-sm">{h.descripcion}</p>
            </CardContent>
          </Card>
        ))}
      </div>

      {selected && (
        <Card className="max-w-md">
          <CardHeader>
            <CardTitle>Reservar Hab. {selected.numero}</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label>Fecha de entrada</Label>
              <Input type="date" value={fechaInicio} onChange={e => setFechaInicio(e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Fecha de salida</Label>
              <Input type="date" value={fechaFin} onChange={e => setFechaFin(e.target.value)} />
            </div>
            {mensaje && (
              <p className={`text-sm ${mensaje.includes('exitosamente') ? 'text-green-600' : 'text-red-500'}`}>
                {mensaje}
              </p>
            )}
            <div className="flex gap-2">
              <Button onClick={handleReservar} disabled={loading} className="flex-1">
                {loading ? 'Reservando...' : 'Confirmar Reserva'}
              </Button>
              <Button variant="outline" onClick={() => setSelected(null)}>Cancelar</Button>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}