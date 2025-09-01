# ⚡ **Configuración Rápida - Google OAuth**

## 🎯 **Para Hacer Funcionar Google Sign-In AHORA**

### **📋 Checklist (15-20 minutos):**

**☑️ 1. GOOGLE CLOUD CONSOLE** (5 mins)
- [ ] Ve a [Google Cloud Console](https://console.cloud.google.com/)
- [ ] Crea proyecto: "Finanzas Personales App"
- [ ] Habilita: Google+ API, Google Sign-In API
- [ ] Crea OAuth 2.0 Client ID (iOS): Bundle ID = `com.tuusuario.finanzas-personales-app`
- [ ] Crea OAuth 2.0 Client ID (Web): Para Supabase
- [ ] Descarga `GoogleService-Info.plist`

**☑️ 2. SUPABASE DASHBOARD** (3 mins)
- [ ] [Supabase Dashboard](https://supabase.com/dashboard) → Authentication → Providers
- [ ] Habilita Google
- [ ] Client ID: (del OAuth Web)
- [ ] Client Secret: (del OAuth Web)
- [ ] Redirect URLs: `finanzas-personales-app://auth/callback`

**☑️ 3. XCODE CONFIGURATION** (2 mins)
- [ ] Arrastra `GoogleService-Info.plist` a Xcode (target principal)
- [ ] Arrastra `Info.plist` a Xcode (target principal)
- [ ] Verifica Bundle ID en Signing & Capabilities

**☑️ 4. PRUEBA** (1 min)
- [ ] `Cmd + R` en Xcode
- [ ] Toca "Iniciar sesión con Google"
- [ ] ✅ Debería funcionar!

---

## 🚨 **URLs Críticas:**

**Google Cloud Console:**
```
https://console.cloud.google.com/
```

**Supabase Dashboard:**
```
https://supabase.com/dashboard
```

**Redirect URL para Supabase:**
```
finanzas-personales-app://auth/callback
```

**Bundle ID (usar consistentemente):**
```
com.tuusuario.finanzas-personales-app
```

---

## 🎯 **Si Algo Falla:**

**❌ "redirect_uri_mismatch"**
→ Verifica Redirect URLs en Supabase

**❌ "invalid_client"** 
→ Verifica Client ID/Secret en Supabase

**❌ No regresa a la app**
→ Verifica Info.plist y URL schemes

**❌ Bundle ID mismatch**
→ Verifica que sea el mismo en Google Cloud y Xcode

---

## 📱 **¡Una Vez Funcione!**

Tu app iOS tendrá:
- ✅ Login real con Google
- ✅ Datos sincronizados con Supabase  
- ✅ Mismos datos que la web
- ✅ Persistencia real
- ✅ Funcionalidad completa

**¡Empezamos con Google Cloud Console! 🚀**
