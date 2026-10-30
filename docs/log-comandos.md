# Log de comandos de Supabase CLI

```bash
# Instalación
npm install supabase --save-dev        # o: brew install supabase/tap/supabase

# Inicializar y vincular
supabase init
supabase login
supabase link --project-ref <PROJECT_REF>

# Crear la migración
supabase migration new inicializar_esquema
# -> Created new migration at supabase/migrations/20261030120000_inicializar_esquema.sql

# Probar en local
supabase start
supabase db reset

# Revisar y aplicar al proyecto remoto
supabase db push --dry-run
supabase db push

# Verificar
supabase migration list
```

| Comando | Función |
|---|---|
| `supabase migration new` | Crea el archivo de migración versionado |
| `supabase db reset` | Recrea la BD local aplicando todas las migraciones |
| `supabase db push` | Aplica las migraciones pendientes al proyecto remoto |
| `supabase migration list` | Compara migraciones locales vs. remotas |
