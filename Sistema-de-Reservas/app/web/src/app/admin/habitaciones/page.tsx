'use client';

import { useEffect, useState } from 'react';
import { habitacionesAPI } from '@/frontend/lib/api';
import { Button } from '@/frontend/components/ui/button';
import { Input } from '@/frontend/components/ui/input';
import { Label } from '@/frontend/components/ui/label';
import { Card, CardContent, CardHeader, CardTitle } from '@/frontend/components/ui/card';
import { Badge } from '@/frontend/components/ui/badge';

interface Habitacion {
  id: string;
  numero: string;
  tipo: string;
  precio_por_noche: number;
  disponible: boolean;
  descripcion: string;
}

export default function HabitacionesPage() {
  const [habitaciones, setHabitaciones] = useState<Habitacion[]>([]);
  const [form, setForm] = useState({ numero: '', tipo: '', precio_por_noche: '', descripcion: '' });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const loadHabitaciones = async () => {
    try {
      const data = await habitacionesAPI.getAll();
      setHabitaciones(data);
    } catch (err) {
      console.error(err);
    }
  };

  useEffect(() => { loadHabitaciones(); }, []);

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      await habitacionesAPI.create({
        ...form,
        precio_por_noche: parseFloat(form.precio_por_noche),
      });
      setForm({ numero: '', tipo: '', precio_por_noche: '', descripcion: '' });
      loadHabitaciones();
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Error al crear habitación');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('¿Eliminar esta habitación?')) return;
    try {
      await habitacionesAPI.delete(id);
      loadHabitaciones();
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Habitaciones</h1>

      <Card>
        <CardHeader><CardTitle>Nueva Habitación</CardTitle></CardHeader>
        <CardContent>
          <form onSubmit={handleCreate} className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label>Número</Label>
              <Input value={form.numero} onChange={e => setForm({...form, numero: e.target.value})} required />
            </div>
            <div className="space-y-2">
              <Label>Tipo</Label>
              <Input value={form.tipo} onChange={e => setForm({...form, tipo: e.target.value})} placeholder="Simple, Doble, Suite" required />
            </div>
            <div className="space-y-2">
              <Label>Precio por noche (S/.)</Label>
              <Input type="number" value={form.precio_por_noche} onChange={e => setForm({...form, precio_por_noche: e.target.value})} required />
            </div>
            <div className="space-y-2">
              <Label>Descripción</Label>
              <Input value={form.descripcion} onChange={e => setForm({...form, descripcion: e.target.value})} />
            </div>
            {error && <p className="col-span-2 text-sm text-red-500">{error}</p>}
            <Button type="submit" className="col-span-2" disabled={loading}>
              {loading ? 'Guardando...' : 'Crear Habitación'}
            </Button>
          </form>
        </CardContent>
      </Card>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {habitaciones.map(h => (
          <Card key={h.id}>
            <CardHeader className="flex flex-row items-center justify-between">
              <CardTitle>Hab. {h.numero}</CardTitle>
              <Badge variant={h.disponible ? 'default' : 'secondary'}>
                {h.disponible ? 'Disponible' : 'Ocupada'}
              </Badge>
            </CardHeader>
            <CardContent className="space-y-2">
              <p className="text-sm text-slate-500">{h.tipo}</p>
              <p className="font-semibold">S/. {h.precio_por_noche} / noche</p>
              <p className="text-sm">{h.descripcion}</p>
              <Button variant="destructive" size="sm" onClick={() => handleDelete(h.id)}>
                Eliminar
              </Button>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}