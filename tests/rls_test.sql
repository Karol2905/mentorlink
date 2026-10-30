-- Prueba manual de RLS (SQL Editor o psql local)
-- Reemplaza los UUID por usuarios reales de auth.users.
begin;
  set local role authenticated;
  set local request.jwt.claims = '{"sub": "<UUID_USUARIO_A>"}';

  select * from public.sesiones;   -- solo sesiones donde A es mentor o estudiante
  select * from public.mensajes;   -- solo mensajes de esas sesiones

  -- Debe FALLAR (suplantación de remitente):
  -- insert into public.mensajes (sesion_id, remitente_id, contenido)
  -- values ('<SESION_ID>', '<UUID_OTRO_USUARIO>', 'hola');
rollback;
