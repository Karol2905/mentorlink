# Prompt de IA utilizado

```text
Actúa como arquitecto de bases de datos senior especializado en PostgreSQL y Supabase.

CONTEXTO
Estoy construyendo "MentorLink", una plataforma que conecta mentores expertos en tecnología con estudiantes. Uso Supabase (PostgreSQL 15 + Supabase Auth). El presupuesto es limitado, así que el diseño debe ser simple, escalable y seguro.

TAREA
Genera UN SOLO script SQL idempotente donde sea posible, listo para ejecutarse como migración, que cree:

1. Tipos ENUM: rol_usuario ('mentor','estudiante') y estado_sesion ('pendiente','confirmada','completada','cancelada').
2. Tabla `perfiles`: id (uuid, PK, FK a auth.users con ON DELETE CASCADE), nombre (text, obligatorio), bio (text), rol (rol_usuario, obligatorio), created_at (timestamptz).
3. Tabla `sesiones`: id (uuid, PK), mentor_id y estudiante_id (FK a perfiles), fecha (timestamptz, obligatoria), estado (estado_sesion, default 'pendiente'), created_at.
4. Tabla `mensajes`: id (bigint identity, PK), sesion_id (FK a sesiones, ON DELETE CASCADE), remitente_id (FK a perfiles), contenido (text), created_at.

RESTRICCIONES
- Foreign Keys con acciones ON DELETE explícitas.
- CHECK: un mentor no puede ser su propio estudiante; el contenido del mensaje no puede estar vacío ni superar 2000 caracteres; el nombre no puede estar vacío.
- Índices en todas las columnas FK y en sesiones(fecha).
- Un trigger sobre auth.users que cree automáticamente el perfil al registrarse (compatible con Email/Password y Google OAuth, tomando el nombre de raw_user_meta_data: 'nombre' o 'full_name'). Usar SECURITY DEFINER con search_path fijo.

SEGURIDAD (RLS)
- Habilitar Row Level Security en las 3 tablas.
- perfiles: lectura para usuarios autenticados; inserción y actualización solo del propio perfil.
- sesiones: un usuario solo puede LEER sesiones donde es mentor o estudiante; solo un estudiante puede crear una sesión a su nombre; solo los participantes pueden actualizarla; nadie puede borrar.
- mensajes: solo se pueden LEER los mensajes de sesiones en las que el usuario participa; solo se pueden INSERTAR mensajes si remitente_id = auth.uid() y el usuario participa en esa sesión.
- Usar (select auth.uid()) en las políticas por rendimiento.

FORMATO DE SALIDA
Solo el código SQL, comentado en español, organizado por secciones numeradas. Después, una lista breve de los riesgos de seguridad que identifiques.
```
