# Guía de configuración de Auth

## Email / Password
1. Dashboard → **Authentication → Sign In / Providers → Email**: verificar que esté habilitado.
2. Activar **Confirm email** (recomendado en producción).
3. Definir longitud mínima de contraseña (8 o más).

## Google OAuth en 3 pasos

**Paso 1 · Credenciales en Google Cloud Console**
1. Crear/seleccionar proyecto en https://console.cloud.google.com.
2. **APIs & Services → OAuth consent screen**: nombre de la app y correo de soporte.
3. **Credentials → Create Credentials → OAuth client ID → Web application**.
4. En **Authorized redirect URIs** agregar: `https://<PROJECT_REF>.supabase.co/auth/v1/callback`
5. Copiar **Client ID** y **Client Secret**.

**Paso 2 · Habilitar Google en Supabase**
1. **Authentication → Sign In / Providers → Google**.
2. Activar **Enable Sign in with Google**.
3. Pegar Client ID y Client Secret → **Save**.

**Paso 3 · URLs y prueba**
1. **Authentication → URL Configuration**: definir **Site URL** y agregar `http://localhost:3000/**` en Redirect URLs.
2. Probar:

```js
await supabase.auth.signInWithOAuth({
  provider: 'google',
  options: { redirectTo: window.location.origin }
})

await supabase.auth.signUp({
  email: 'ana@correo.com',
  password: 'ContraseñaSegura123',
  options: { data: { nombre: 'Ana Pérez', rol: 'estudiante' } }
})
```
3. Verificar en **Authentication → Users** y en **Table Editor → perfiles** que el perfil se creó por el trigger.
