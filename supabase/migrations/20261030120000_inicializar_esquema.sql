-- =====================================================================
-- MentorLink · Migración inicial
-- =====================================================================

-- 1. TIPOS ENUM
create type public.rol_usuario   as enum ('mentor', 'estudiante');
create type public.estado_sesion as enum ('pendiente', 'confirmada', 'completada', 'cancelada');

-- 2. TABLAS
create table public.perfiles (
  id         uuid primary key references auth.users (id) on delete cascade,
  nombre     text not null check (length(trim(nombre)) > 0),
  bio        text,
  rol        public.rol_usuario not null default 'estudiante',
  created_at timestamptz not null default now()
);
comment on table public.perfiles is 'Perfil público de cada usuario (mentor o estudiante).';

create table public.sesiones (
  id            uuid primary key default gen_random_uuid(),
  mentor_id     uuid not null references public.perfiles (id) on delete cascade,
  estudiante_id uuid not null references public.perfiles (id) on delete cascade,
  fecha         timestamptz not null,
  estado        public.estado_sesion not null default 'pendiente',
  created_at    timestamptz not null default now(),
  constraint sesiones_mentor_distinto_estudiante check (mentor_id <> estudiante_id)
);
comment on table public.sesiones is 'Sesiones de mentoría entre un mentor y un estudiante.';

create table public.mensajes (
  id           bigint generated always as identity primary key,
  sesion_id    uuid not null references public.sesiones (id) on delete cascade,
  remitente_id uuid not null references public.perfiles (id) on delete cascade,
  contenido    text not null check (length(trim(contenido)) > 0 and length(contenido) <= 2000),
  created_at   timestamptz not null default now()
);
comment on table public.mensajes is 'Mensajes de chat asociados a una sesión.';

-- 3. ÍNDICES
create index idx_sesiones_mentor_id     on public.sesiones (mentor_id);
create index idx_sesiones_estudiante_id on public.sesiones (estudiante_id);
create index idx_sesiones_fecha         on public.sesiones (fecha);
create index idx_mensajes_sesion_id     on public.mensajes (sesion_id, created_at);
create index idx_mensajes_remitente_id  on public.mensajes (remitente_id);

-- 4. TRIGGER: perfil automático al registrarse (Email/Password y Google)
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_nombre text;
  v_rol    public.rol_usuario;
begin
  v_nombre := coalesce(
    nullif(trim(new.raw_user_meta_data ->> 'nombre'), ''),
    nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''),
    split_part(new.email, '@', 1)
  );

  v_rol := case
             when new.raw_user_meta_data ->> 'rol' = 'mentor' then 'mentor'::public.rol_usuario
             else 'estudiante'::public.rol_usuario
           end;

  insert into public.perfiles (id, nombre, rol) values (new.id, v_nombre, v_rol);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 5. ROW LEVEL SECURITY
alter table public.perfiles enable row level security;
alter table public.sesiones enable row level security;
alter table public.mensajes enable row level security;

-- 5.1 perfiles
create policy "perfiles_select_autenticados" on public.perfiles
  for select to authenticated using (true);

create policy "perfiles_insert_propio" on public.perfiles
  for insert to authenticated with check (id = (select auth.uid()));

create policy "perfiles_update_propio" on public.perfiles
  for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- 5.2 sesiones
create policy "sesiones_select_participantes" on public.sesiones
  for select to authenticated
  using ((select auth.uid()) in (mentor_id, estudiante_id));

create policy "sesiones_insert_estudiante" on public.sesiones
  for insert to authenticated
  with check (estudiante_id = (select auth.uid()));

create policy "sesiones_update_participantes" on public.sesiones
  for update to authenticated
  using      ((select auth.uid()) in (mentor_id, estudiante_id))
  with check ((select auth.uid()) in (mentor_id, estudiante_id));
-- Sin política DELETE: nadie puede borrar sesiones.

-- 5.3 mensajes
create policy "mensajes_select_participantes" on public.mensajes
  for select to authenticated
  using (exists (
    select 1 from public.sesiones s
    where s.id = mensajes.sesion_id
      and (select auth.uid()) in (s.mentor_id, s.estudiante_id)
  ));

create policy "mensajes_insert_remitente_participante" on public.mensajes
  for insert to authenticated
  with check (
    remitente_id = (select auth.uid())
    and exists (
      select 1 from public.sesiones s
      where s.id = mensajes.sesion_id
        and (select auth.uid()) in (s.mentor_id, s.estudiante_id)
    )
  );
-- Sin UPDATE/DELETE: los mensajes son inmutables.
