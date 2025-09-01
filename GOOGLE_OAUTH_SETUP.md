# 🔧 Configuración Completa de Google OAuth para iOS

## 📋 **Configuraciones Necesarias (3 Pasos)**

### **🎯 PASO 1: Google Cloud Console - Crear Credenciales OAuth**

#### **A. Acceder a Google Cloud Console:**
1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. **Inicia sesión** con tu cuenta Google
3. **Crea un nuevo proyecto** o selecciona uno existente:
   - **Nombre**: `Finanzas Personales App`
   - **ID**: puede ser generado automáticamente

#### **B. Habilitar APIs:**
1. Ve a **"APIs & Services" > "Library"**
2. Busca y habilita:
   - **Google+ API**
   - **Google Sign-In API** 
   - **Google Identity Services**

#### **C. Crear Credenciales OAuth 2.0:**

**Para iOS:**
1. Ve a **"APIs & Services" > "Credentials"**
2. Clic **"+ CREATE CREDENTIALS" > "OAuth 2.0 Client ID"**
3. Selecciona **"iOS"** como Application type
4. Configura:
   - **Name**: `Finanzas Personales iOS`
   - **Bundle ID**: `com.tuusuario.finanzas-personales-app`
   
   **⚠️ IMPORTANTE:** El Bundle ID debe coincidir exactamente con el de tu proyecto Xcode.

**Para Web (Supabase):**
1. Crea OTRO OAuth Client ID
2. Selecciona **"Web Application"**
3. Configura:
   - **Name**: `Finanzas Personales Web`
   - **Authorized redirect URIs**:
     ```
     https://tu-proyecto.supabase.co/auth/v1/callback
     ```
     **Reemplaza `tu-proyecto` con tu URL real de Supabase**

#### **D. Guardar Credenciales:**
- **Client ID (iOS)**: Lo necesitas para Xcode
- **Client ID (Web)**: Lo necesitas para Supabase  
- **Client Secret (Web)**: Lo necesitas para Supabase

---

### **🎯 PASO 2: Configurar Supabase Dashboard**

#### **A. Habilitar Google Provider:**
1. Ve a tu proyecto en [Supabase Dashboard](https://supabase.com/dashboard)
2. **Authentication > Providers**
3. Encuentra **"Google"** y haz clic en **"Enable"**

#### **B. Configurar Credenciales:**
Usa las credenciales del **OAuth Client Web** (no iOS):
```
Client ID: [Client ID del OAuth Web que creaste]
Client Secret: [Client Secret del OAuth Web]
```

#### **C. Configurar Redirect URLs:**
1. Ve a **Authentication > URL Configuration**
2. En **"Redirect URLs"**, agrega:
```
finanzas-personales-app://auth/callback
```

#### **D. Site URL:**
Si tienes una web:
```
https://tu-dominio.com
```
Si solo tienes la app:
```
finanzas-personales-app://
```

---

### **🎯 PASO 3: Configurar Proyecto Xcode**

#### **A. Agregar Info.plist al Proyecto:**
1. En Xcode, **arrastra** el archivo `Info.plist` al target principal
2. Asegúrate que esté marcado para **"finanzas-personales-app"** target

#### **B. Crear GoogleService-Info.plist:**
1. En Google Cloud Console, ve a tu proyecto iOS
2. **Descarga** el archivo `GoogleService-Info.plist`
3. **Arrastra** el archivo a tu proyecto Xcode
4. Asegúrate que esté incluido en el target

**Si no tienes el archivo, crea uno temporal:**

\`\`\`xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CLIENT_ID</key>
    <string>TU_CLIENT_ID_IOS_AQUI</string>
    <key>REVERSED_CLIENT_ID</key>
    <string>com.googleusercontent.apps.TU_REVERSED_CLIENT_ID</string>
</dict>
</plist>
\`\`\`

---

## 🧪 **PASO 4: Probar la Configuración**

### **Compilar y Probar:**
1. **Conecta tu iPhone** al Mac
2. **Presiona `Cmd + R`** en Xcode
3. **Toca "Iniciar sesión con Google"**
4. **Debería abrir Safari/Chrome** para login
5. **Después del login**, debería redirigir a tu app

### **¿Qué Esperar?**
- ✅ **Se abre navegador** para login Google
- ✅ **Login exitoso** en Google
- ✅ **Regresa a tu app** automáticamente
- ✅ **Usuario aparece loggeado** en la app

### **Problemas Comunes:**

**❌ Error: "redirect_uri_mismatch"**
- Verifica que las Redirect URLs en Supabase sean correctas

**❌ No regresa a la app después del login:**
- Verifica que el URL Scheme esté configurado correctamente
- Verifica que el Bundle ID coincida

**❌ Error de certificado:**
- Asegúrate que el Bundle ID en Google Cloud coincida con Xcode

---

## 🎯 **Resumen de URLs y Configuraciones:**

### **URLs Importantes:**
- **Google Cloud**: https://console.cloud.google.com/
- **Supabase**: https://supabase.com/dashboard
- **Redirect URL**: `finanzas-personales-app://auth/callback`

### **Bundle ID Consistency:**
Asegúrate que sea el MISMO en:
- ✅ Xcode project settings
- ✅ Google Cloud OAuth iOS client
- ✅ GoogleService-Info.plist

---

## 🚨 **¡IMPORTANTE!**

1. **Usa diferentes Client ID/Secret** para iOS vs Web
2. **El Bundle ID** debe ser único y consistente
3. **Las Redirect URLs** deben ser exactas
4. **Prueba primero** con tu dispositivo antes de distribuir

Una vez configurado correctamente, tendrás **autenticación Google real** funcionando en tu app iOS! 🚀
