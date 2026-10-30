# MentorLink · Infraestructura con Supabase e IA

Proyecto integrador "La Base (Supabase y Auth)". Rol: **Arquitecto IA**.
Stack: Supabase (PostgreSQL + Auth) + Supabase CLI.

## Estructura del repositorio

```
mentorlink/
├── README.md
├── .env.example
├── .gitignore
├── supabase/
│   ├── config.toml
│   └── migrations/20261030120000_inicializar_esquema.sql
├── tests/rls_test.sql
└── docs/
    ├── prompt-ia.md
    ├── log-comandos.md
    └── guia-auth.md
```

## Entregables

| Entregable | Ubicación |
|---|---|
| Scripts SQL (tablas + RLS) | `supabase/migrations/20261030120000_inicializar_esquema.sql` |
| Prompt de IA utilizado | `docs/prompt-ia.md` |
| Log de comandos CLI | `docs/log-comandos.md` |
| Guía de configuración Auth (Google) | `docs/guia-auth.md` |

## Modelo de datos

- **perfiles**: `id` (FK → auth.users), `nombre`, `bio`, `rol` (mentor | estudiante), `created_at`.
- **sesiones**: `id`, `mentor_id` → perfiles, `estudiante_id` → perfiles, `fecha`, `estado`, `created_at`. CHECK: mentor ≠ estudiante.
- **mensajes**: `id`, `sesion_id` → sesiones, `remitente_id` → perfiles, `contenido` (1–2000 caracteres), `created_at`.

## Seguridad (RLS)

- Perfiles: lectura para autenticados; insert/update solo del propio perfil.
- Sesiones: lectura y actualización solo para participantes; creación solo por el estudiante; sin DELETE.
- Mensajes: lectura solo en sesiones propias; inserción solo si `remitente_id = auth.uid()` y es participante; inmutables.
- Trigger `handle_new_user` (SECURITY DEFINER, `search_path = ''`) crea el perfil al registrarse con Email o Google.

## Uso rápido

```bash
supabase link --project-ref <PROJECT_REF>
supabase db push
```

## Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| Escalada de rol vía metadata | El trigger solo acepta `mentor`/`estudiante` |
| Cambio de participantes en UPDATE | `WITH CHECK` exige seguir siendo participante (mejora futura: trigger que bloquee cambios de `mentor_id`, `estudiante_id`, `fecha`) |
| Suplantación de remitente | `WITH CHECK (remitente_id = auth.uid())` |
| Fuga por SECURITY DEFINER | `search_path = ''` y objetos cualificados |
| Borrado de historial | Sin políticas DELETE |
