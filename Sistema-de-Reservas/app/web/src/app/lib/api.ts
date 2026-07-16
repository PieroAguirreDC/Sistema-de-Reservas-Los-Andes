const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api/v1';

async function fetchAPI(endpoint: string, options?: RequestInit) {
  const res = await fetch(`${API_URL}${endpoint}`, {
    headers: {
      'Content-Type': 'application/json',
      ...options?.headers,
    },
    ...options,
  });

  if (!res.ok) {
    const error = await res.json().catch(() => ({}));
    throw new Error(error.message || 'Error en la petición');
  }

  return res.json();
}

// Habitaciones
export const habitacionesAPI = {
  getAll: () => fetchAPI('/habitaciones'),
  getOne: (id: string) => fetchAPI(`/habitaciones/${id}`),
  create: (data: object) => fetchAPI('/habitaciones', { method: 'POST', body: JSON.stringify(data) }),
  update: (id: string, data: object) => fetchAPI(`/habitaciones/${id}`, { method: 'PUT', body: JSON.stringify(data) }),
  delete: (id: string) => fetchAPI(`/habitaciones/${id}`, { method: 'DELETE' }),
};

// Reservas
export const reservasAPI = {
  getAll: () => fetchAPI('/reservas'),
  getOne: (id: string) => fetchAPI(`/reservas/${id}`),
  create: (data: object) => fetchAPI('/reservas', { method: 'POST', body: JSON.stringify(data) }),
  update: (id: string, data: object) => fetchAPI(`/reservas/${id}`, { method: 'PUT', body: JSON.stringify(data) }),
  delete: (id: string) => fetchAPI(`/reservas/${id}`, { method: 'DELETE' }),
};

// Usuarios
export const usuariosAPI = {
  getAll: () => fetchAPI('/usuarios'),
  getOne: (id: string) => fetchAPI(`/usuarios/${id}`),
  create: (data: object) => fetchAPI('/usuarios', { method: 'POST', body: JSON.stringify(data) }),
  update: (id: string, data: object) => fetchAPI(`/usuarios/${id}`, { method: 'PUT', body: JSON.stringify(data) }),
  delete: (id: string) => fetchAPI(`/usuarios/${id}`, { method: 'DELETE' }),
};

// Auth
export const authAPI = {
  login: (data: { email: string; password: string }) =>
    fetchAPI('/usuarios/login', { method: 'POST', body: JSON.stringify(data) }),
  register: (data: { nombre: string; email: string; password: string }) =>
    fetchAPI('/usuarios/register', { method: 'POST', body: JSON.stringify(data) }),
};